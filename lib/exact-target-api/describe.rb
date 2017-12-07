module ET
  class Describe < ET::Constructor
    def initialize(authStub = nil, obj_type = nil)
      authStub.refresh_token
      response = authStub.auth.call(
        :describe,
        message: {
          'DescribeRequests' => {
            'ObjectDefinitionRequest' => { 'ObjectType' => obj_type }
          }
        }
      )
    ensure
      super(response)

      if @status
        obj_def = @body[:definition_response_msg][:object_definition]

        @overallStatus = !obj_def.nil?
        @results = @body[:definition_response_msg][:object_definition][:properties]
      end
    end
  end
end
