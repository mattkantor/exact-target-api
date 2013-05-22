module ET
  class Patch < ET::Constructor
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

        response = authStub.auth.call(:update, :message => obj)

      ensure
        super(response)
        if @status
          if @body[:update_response][:overall_status] != "OK"
            @status = false
          end
          if !@body[:update_response][:results].is_a? Hash then
            @results = @results + @body[:update_response][:results]
          else
            @results.push(@body[:update_response][:results])
          end
        end
      end
    end
  end
end