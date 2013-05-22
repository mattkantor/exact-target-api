module ET
  class PatchRest < ET::Constructor
    def initialize(authStub, endpoint, payload)
      authStub.refreshToken

      qs = {"access_token" => authStub.authToken}
      uri = URI.parse(endpoint)
      uri.query = URI.encode_www_form(qs)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Patch.new(uri.request_uri)
      request.body = 	payload.to_json
      request.add_field "Content-Type", "application/json"
      requestResponse = http.request(request)
      super(requestResponse, true)

    end
  end
end