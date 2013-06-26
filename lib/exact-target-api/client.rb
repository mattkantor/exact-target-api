require 'tmpdir'

module ET
  class Client < ET::CreateWSDL
    attr_accessor :auth, :ready, :status, :debug, :authToken
    attr_reader :authTokenExpiration, :internalAuthToken, :wsdlLoc, :clientId, :clientSecret, :soapHeader, :authObj, :path, :appsignature, :stackID, :refreshKey

    def initialize(config, options = {})
      load_config(config)
      symbolize_keys!(options)

      get_wsdl = options.has_key?(:wsdl) ? options[:wsdl] : true

      @debug = options[:debug]

      @path = Dir.tmpdir

      begin
        if get_wsdl
          super(@path)
        end

        if options[:jwt]
          jwt = JWT.decode(options[:jwt], @appsignature, true)
          @authToken = jwt['request']['user']['oauthToken']
          @authTokenExpiration = [Time.at(jwt['exp']), Time.now + jwt['request']['user']['expiresIn']].min
          @internalAuthToken = jwt['request']['user']['internalOauthToken']
          @refreshKey = jwt['request']['user']['refreshToken']

          self.determineStack

          @authObj = {'oAuth' => {'oAuthToken' => @internalAuthToken}}
          @authObj[:attributes!] = { 'oAuth' => { 'xmlns' => 'http://exacttarget.com' }}

          @auth = Savon.client(soap_header: @authObj,
                               wsdl: File.read(wsdl_file(@path)),
                               endpoint: @endpoint,
                               wsse_auth: ["*", "*"],
                               raise_errors: false,
                               log: @debug,
                               open_timeout: 180,
                               read_timeout: 180)
        end
        refreshToken
      rescue
        raise
      end

      @ready = @auth.operations.length > 0 && @status >= 200 && @status <= 400
    end

    def refreshToken(force = nil)
      #If we don't already have a token or the token expires within 5 min(300 seconds), get one
      if force || @authToken.nil? || Time.now + 300 > @authTokenExpiration
        begin
          uri = URI.parse("https://auth.exacttargetapis.com/v1/requestToken?legacy=1")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Post.new(uri.request_uri)

          jsonPayload = {clientId: @clientId, clientSecret: @clientSecret, accessType: 'offline'}
          # Pass in the refreshKey if we have it
          if @refreshKey
            jsonPayload[:refreshToken] = @refreshKey
            jsonPayload[:scope] = "cas:#{@internalAuthToken}"
          end
          request.body = jsonPayload.to_json
          request.add_field "Content-Type", "application/json"
          tokenResponse = JSON.parse(http.request(request).body)

          if tokenResponse['accessToken'].nil?
            raise 'Unable to validate App Keys(ClientID/ClientSecret) provided: ' + http.request(request).body
          end

          @authToken = tokenResponse['accessToken']
          @authTokenExpiration = Time.new + tokenResponse['expiresIn']
          @internalAuthToken = tokenResponse['legacyToken']
          if tokenResponse["refreshToken"]
            @refreshKey = tokenResponse['refreshToken']
          end


          self.determineStack if @endpoint.nil?

          @authObj = {'oAuth' => {'oAuthToken' => @internalAuthToken}}
          @authObj[:attributes!] = {'oAuth' => {'xmlns' => 'http://exacttarget.com' }}

          @auth = Savon.client(soap_header: @authObj,
                               wsdl: File.read(wsdl_file(@path)),
                               endpoint: @endpoint,
                               wsse_auth: ["*", "*"],
                               raise_errors: false,
                               log: @debug)


        rescue Exception => e
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

    #def AddSubscriberToList(emailAddress, listIDs, subscriberKey = nil)
    #  newSub = ET::Subscriber.new
    #  newSub.authStub = self
    #  lists = []
    #
    #  listIDs.each{ |p|
    #    lists.push({"ID"=> p})
    #  }
    #
    #  newSub.props = {"EmailAddress" => emailAddress, "Lists" => lists}
    #  if !subscriberKey.nil?
    #    newSub.props['SubscriberKey']  = subscriberKey
    #  end
    #
    #  # Try to add the subscriber
    #  postResponse = newSub.post
    #
    #  if !postResponse.status
    #    # If the subscriber already exists in the account then we need to do an update.
    #    # Update Subscriber On List
    #    if postResponse.results[0][:error_code] == "12014"
    #      patchResponse = newSub.patch
    #      return patchResponse
    #    end
    #  end
    #  postResponse
    #end

    #def CreateDataExtensions(dataExtensionDefinitions)
    #  newDEs = ET::DataExtension.new
    #  newDEs.authStub = self
    #
    #  newDEs.props = dataExtensionDefinitions
    #  newDEs.post
    #end


    protected


    def load_config(config)
      symbolize_keys!(config)

      @clientId = config[:clientid] || raise("Please provide ClientID")
      @clientSecret = config[:clientsecret] || raise("Please provide Client Secret")
      @appsignature = config[:appsignature]
      @wsdl = config[:defaultwsdl] || 'https://webservice.exacttarget.com/etframework.wsdl'
    end

    def determineStack
      begin
        uri = URI.parse("https://www.exacttargetapis.com/platform/v1/endpoints/soap?access_token=" + @authToken)
        http = Net::HTTP.new(uri.host, uri.port)

        http.use_ssl = true

        request = Net::HTTP::Get.new(uri.request_uri)

        contextResponse = JSON.parse(http.request(request).body)
        @endpoint = contextResponse['url']

      rescue Exception => e
        raise 'Unable to determine stack using /platform/v1/tokenContext: ' + e.message
      end
    end
  end
end
