module ET
  class DeleteRest < ET::Constructor
    def initialize(authStub, endpoint)
      authStub.refreshToken

      qs = {"access_token" => authStub.authToken}

      uri = URI.parse(endpoint)
      uri.query = URI.encode_www_form(qs)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Delete.new(uri.request_uri)
      requestResponse = http.request(request)
      super(requestResponse, true)

    end
  end
end