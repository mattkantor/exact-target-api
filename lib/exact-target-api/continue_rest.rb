module ET
  class ContinueRest < ET::Constructor
    def initialize(authStub, endpoint, qs = nil)
      authStub.refresh_token

      if qs
        qs['access_token'] = authStub.access_token
      else
        qs = {"access_token" => authStub.access_token}
      end

      uri = URI.parse(endpoint)
      uri.query = URI.encode_www_form(qs)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)
      requestResponse = http.request(request)

      @moreResults = false

      super(requestResponse, true)
    end
  end
end
