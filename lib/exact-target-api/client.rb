require 'tmpdir'

module ET
  class Client < ET::CreateWSDL
    attr_accessor :auth, :ready, :status, :debug, :authToken
    attr_reader :wsdlLoc, :clientId, :clientSecret, :path, :appsignature

    def initialize(config, options = {})
      load_config(config)
      symbolize_keys!(options)
      get_wsdl = options.key?(:wsdl) ? options[:wsdl] : true
      @debug = options[:debug]
      @path = Dir.tmpdir

      @refresh_key = options[:refresh_token]
      @auth_endpoint = options[:auth_endpoint]
      @exp = options[:exp]
      @access_token = options[:access_token]

      begin
        super(@path) if get_wsdl
        refresh_token()
        auth_client()
      rescue
        raise
      end

      @ready = !@auth.operations.empty? &&
               @status && @status >= 200 && @status <= 400
    end

    def refresh_token(force = nil)
      if force || @access_token.nil? || token_expired?
        token = get_token
        @exp = (Time.now.utc + token['expiresIn']).to_i
        @access_token = token['accessToken']
        @refresh_key = token['refreshToken'] if token['refreshToken'].present?
        auth_client()
      end
    end

    def data_extension
      ET::DataExtension.new(self)
    end

    def data_extension_row(customer_key: nil, name: nil)
      row = ET::DataExtension::Row.new(self)
      row.CustomerKey = customer_key if customer_key.present?
      row.Name = name if name.present?
      row
    end

    def list
      ET::List.new(self)
    end

    def subscriber(list_id = nil)
      ET::Subscriber.new(self, list_id)
    end

    def folders
      ET::Folders.new(self)
    end

    def list_subscriber
      ET::List::Subscriber.new(self)
    end

    def subscriber_list
      ET::Subscriber::List.new(self)
    end

    protected

    def load_config(config)
      symbolize_keys!(config)

      @clientId = config[:clientid] || raise('Please provide ClientID')
      @clientSecret = config[:clientsecret] || raise('Please provide Client Secret')
      @appsignature = config[:appsignature]
      @wsdl = config[:defaultwsdl] || 'https://webservice.exacttarget.com/etframework.wsdl'
    end

    def get_token
      uri = URI.parse(@auth_endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      hash = { clientId: @clientId, clientSecret: @clientSecret }
      # accessType: 'offline'
      hash[:refreshToken] = @refresh_key if @access_token.present?

      request.body = hash.to_json
      request.add_field 'Content-Type', 'application/json'
      response = http.request(request)
      token_response = JSON.parse(response.body)
      if token_response['accessToken'].nil?
        raise 'Unable to validate App Keys(ClientID/ClientSecret) provided: ' + http.request(request).body
      end
      token_response
    end

    def get_soap_endpoint(access_token)
      uri = URI.parse('https://www.exacttargetapis.com/platform/v1/endpoints/soap?access_token=' + access_token)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)
      contextResponse = JSON.parse(http.request(request).body)
      contextResponse['url']
    rescue StandardError => e
      raise 'Unable to determine stack using /platform/v1/tokenContext: ' + e.message
    end

    def get_soap_header(access_token)
      { 'fueloauth' => access_token }
    end

    def token_expired?
      Time.now.to_i + 60 > @exp.to_i
    end

    def auth_client
      soap_endpoint = get_soap_endpoint(@access_token)
      soap_header = get_soap_header(@access_token)

      @auth = Savon.client(
        soap_header: soap_header, wsdl: File.read(wsdl_file(@path)),
        endpoint: soap_endpoint, raise_errors: false,
        pretty_print_xml: @debug, log: @debug
      )
    end
  end
end
