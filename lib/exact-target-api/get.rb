module ET
  class Get < ET::Constructor
    def initialize(client, objType, props = nil, filter = nil)
      @results = []
      client.refreshToken
      if !props
        resp = ET::Describe.new(client, objType)
        if resp
          props = []
          resp.results.map { |p|
            if p[:is_retrievable]
              props << p[:name]
            end
          }
        end
      end

      # If the properties is a hash, then we just want to use the keys
      if props.is_a? Hash then
        obj = {'ObjectType' => objType,'Properties' => props.keys}
      else
        obj = {'ObjectType' => objType,'Properties' => props}
      end

      if filter then
        if filter.has_key?('LogicalOperator')
          obj['Filter'] = filter
          obj[:attributes!] = { 'Filter' => { 'xsi:type' => 'tns:ComplexFilterPart' }}
          obj['Filter'][:attributes!] = { 'LeftOperand' => { 'xsi:type' => 'tns:SimpleFilterPart' }, 'RightOperand' => { 'xsi:type' => 'tns:SimpleFilterPart' }}
        else
          obj['Filter'] = filter
          obj[:attributes!] = { 'Filter' => { 'xsi:type' => 'tns:SimpleFilterPart' } }
        end
      end

      response = client.auth.call(:retrieve, message: {
        'RetrieveRequest' => obj
      })

      super(response)

      if @status
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