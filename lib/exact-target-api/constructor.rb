module ET
  class Constructor
    attr_accessor :status, :code, :message, :results, :request_id, :moreResults

    def initialize(response = nil, rest = false)
      @results = []
      if !response.nil? && !rest
        envelope = response.hash[:envelope]
        @body = envelope[:body]

        if !response.soap_fault? || !response.http_error?
          @code = response.http.code
          @status = true
        elsif response.soap_fault?
          @code = response.http.code
          @message = @body[:fault][:faultstring]
          @status = false
        elsif response.http_error?
          @code = response.http.code
          @status = false
        end
      elsif (@code = response.code)

        @status = @code == "200"

        begin
          @results = JSON.parse(response.body)
        rescue
          @message = response.body
        end
      end
    end
  end
end