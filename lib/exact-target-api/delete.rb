module ET
  class Delete < ET::Constructor
    def initialize(authStub, objType, props = nil)
      @results = []
      begin
        authStub.refreshToken
        if props.is_a? Array
          obj = {
            'Objects' => [],
            :attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + objType) } }
          }
          props.each{ |p|
            obj['Objects'] << p
          }
        else
          obj = {
            'Objects' => props,
            :attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + objType) } }
          }
        end

        response = authStub.auth.call(:delete, :message => obj)
      ensure
        super(response)
        if @status
          if @body[:delete_response][:overall_status] != "OK"
            @status = false
          end
          if !@body[:delete_response][:results].is_a? Hash
            @results = @results + @body[:delete_response][:results]
          else
            @results.push(@body[:delete_response][:results])
          end
        end
      end
    end
  end
end