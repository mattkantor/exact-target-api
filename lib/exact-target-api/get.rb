module ET
  class Get < ET::Constructor
    def initialize(client, obj_type, props = nil, filter = nil)
      response = make_request(client, obj_type, props, filter)
      if @token_expired
        client.refresh_token(true)
        response = make_request(client, obj_type, props, filter)
      end
      response
    end

    def make_request(client, obj_type, props, filter)
      @results = []
      client.refresh_token
      unless props
        resp = ET::Describe.new(client, obj_type)
        if resp
          props = []
          resp.results.map do |p|
            props << p[:name] if p[:is_retrievable]
          end
        end
      end

      # If the properties is a hash, then we just want to use the keys
      obj = if props.is_a?(Hash)
              { 'ObjectType' => obj_type, 'Properties' => props.keys }
            else
              { 'ObjectType' => obj_type, 'Properties' => props }
            end

      if filter
        if filter.key?('LogicalOperator')
          obj['Filter'] = filter.merge('@xsi:type' => 'tns:ComplexFilterPart')
          obj['Filter']['LeftOperand']['@xsi:type'] = 'tns:SimpleFilterPart'
          obj['Filter']['RightOperand']['@xsi:type'] = 'tns:SimpleFilterPart'
        else
          obj['Filter'] = filter.merge('@xsi:type' => 'tns:SimpleFilterPart')
        end
      end

      response = client.auth.call(
        :retrieve, message: { 'RetrieveRequest' => obj }
      )

      super(response)

      return unless @status

      if @body[:retrieve_response_msg][:overall_status] != 'OK' &&
         @body[:retrieve_response_msg][:overall_status] != 'MoreDataAvailable'
        @status = false
        @message = @body[:retrieve_response_msg][:overall_status]
      end

      @moreResults = false
      if @body[:retrieve_response_msg][:overall_status] == 'MoreDataAvailable'
        @moreResults = true
      end

      if !@body[:retrieve_response_msg][:results].is_a?(Hash) &&
         !@body[:retrieve_response_msg][:results].nil?
        @results += @body[:retrieve_response_msg][:results]
      elsif !@body[:retrieve_response_msg][:results].nil?
        @results.push(@body[:retrieve_response_msg][:results])
      end

      # Store the Last Request ID for use with continue
      @request_id = @body[:retrieve_response_msg][:request_id]
    end
  end
end
