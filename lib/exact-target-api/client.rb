require 'tmpdir'

module ET
  class Client < ET::CreateWSDL
    attr_accessor :auth, :ready, :status, :debug, :authToken
    attr_reader :authTokenExpiration, :internalAuthToken, :wsdlLoc, :clientId,
                :clientSecret, :soapHeader, :authObj, :path, :appsignature,
                :stackID, :refreshKey

    def initialize(config, options = {})
      load_config(config)
      symbolize_keys!(options)
      get_wsdl = options.key?(:wsdl) ? options[:wsdl] : true
      @debug = options[:debug]
      @path = Dir.tmpdir

      begin
        super(@path) if get_wsdl

        if options[:jwt]
          jwt = JWT.decode(options[:jwt], @appsignature, true)[0]
          @authToken = jwt['request']['user']['oauthToken']
          @authTokenExpiration = [Time.at(jwt['exp']).utc, Time.now.utc + jwt['request']['user']['expiresIn']].min
          @internalAuthToken = jwt['request']['user']['internalOauthToken']
          @refreshKey = jwt['request']['user']['refreshToken']

          determine_stack

          @authObj = {
            'oAuth' => {
              'oAuthToken' => @internalAuthToken,
              '@xmlns' => 'http://exacttarget.com'
            }
          }

          @auth = Savon.client(soap_header: @authObj,
                               wsdl: File.read(wsdl_file(@path)),
                               endpoint: @endpoint,
                               wsse_auth: ["*", "*"],
                               raise_errors: false,
                               log: @debug,
                               open_timeout: 180,
                               read_timeout: 180)
        end
        refresh_token
      rescue
        raise
      end

      @ready = !@auth.operations.empty? &&
               @status && @status >= 200 && @status <= 400
    end

    def refresh_token(force = nil)
      # If we don't have a token or the token expires within 1 min, get one
      if force || @authToken.nil? || Time.now.utc + 60 > @authTokenExpiration
        begin
          uri = URI.parse('https://auth.exacttargetapis.com/v1/requestToken?legacy=1')
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Post.new(uri.request_uri)

          json_payload = {
            clientId: @clientId,
            clientSecret: @clientSecret,
            accessType: 'offline'
          }
          if @refreshKey
            json_payload[:refreshToken] = @refreshKey
            json_payload[:scope] = "cas:#{@internalAuthToken}"
          end
          request.body = json_payload.to_json
          request.add_field 'Content-Type', 'application/json'
          token_response = JSON.parse(http.request(request).body)

          if token_response['accessToken'].nil?
            raise 'Unable to validate App Keys(ClientID/ClientSecret) provided: ' + http.request(request).body
          end

          @authToken = token_response['accessToken']
          @authTokenExpiration = Time.new.utc + token_response['expiresIn']
          @internalAuthToken = token_response['legacyToken']
          if token_response['refreshToken']
            @refreshKey = token_response['refreshToken']
          end

          determine_stack if @endpoint.nil?

          @authObj = {
            'oAuth' => {
              'oAuthToken' => @internalAuthToken,
              '@xmlns' => 'http://exacttarget.com'
            }
          }

          @auth = Savon.client(soap_header: @authObj,
                               wsdl: File.read(wsdl_file(@path)),
                               endpoint: @endpoint,
                               wsse_auth: ["*", "*"],
                               raise_errors: false,
                               log: @debug)
        rescue StandardError => e
          raise 'Unable to validate App Keys(ClientID/ClientSecret) provided: ' + e.message
        end
      end
    end

    def list
      ET::List.new(self)
    end

    def subscriber
      ET::Subscriber.new(self)
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

    def determine_stack
      uri = URI.parse('https://www.exacttargetapis.com/platform/v1/endpoints/soap?access_token=' + @authToken)
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)

      contextResponse = JSON.parse(http.request(request).body)
      @endpoint = contextResponse['url']

    rescue StandardError => e
      raise 'Unable to determine stack using /platform/v1/tokenContext: ' +
            e.message
    end

    alias_method :refreshToken, :refresh_token
  end
end
