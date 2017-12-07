module ET
  class DeleteRest < ET::Constructor
    def initialize(authStub, endpoint)
      authStub.refresh_token

      qs = {"access_token" => authStub.access_token}

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
