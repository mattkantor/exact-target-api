module ET
  class Describe < ET::Constructor
    def initialize(authStub = nil, objType = nil)
      begin
        authStub.refreshToken
        response = authStub.auth.call(:describe, :message => {
          'DescribeRequests' =>
            {'ObjectDefinitionRequest' =>
               {'ObjectType' => objType}
            }
        })
      ensure
        super(response)

        if @status
          objDef = @body[:definition_response_msg][:object_definition]


          @overallStatus = !!objDef
          @results = @body[:definition_response_msg][:object_definition][:properties]
        end
      end
    end
  end
end