module ET
  class Continue < ET::Constructor
    def initialize(authStub, request_id)
      @results = []
      authStub.refresh_token
      obj = {'ContinueRequest' => request_id}
      response = authStub.auth.call(:retrieve, :message => {'RetrieveRequest' => obj})

      super(response)

      if @status then
        if @body[:retrieve_response_msg][:overall_status] != "OK" && @body[:retrieve_response_msg][:overall_status] != "MoreDataAvailable" then
          @status = false
          @message = @body[:retrieve_response_msg][:overall_status]
        end

        @moreResults = false
        if @body[:retrieve_response_msg][:overall_status] == "MoreDataAvailable" then
          @moreResults = true
        end

        if (!@body[:retrieve_response_msg][:results].is_a? Hash) && (!@body[:retrieve_response_msg][:results].nil?) then
          @results = @results + @body[:retrieve_response_msg][:results]
        elsif  (!@body[:retrieve_response_msg][:results].nil?)
          @results.push(@body[:retrieve_response_msg][:results])
        end

        # Store the Last Request ID for use with continue
        @request_id = @body[:retrieve_response_msg][:request_id]
      end
    end
  end
end
