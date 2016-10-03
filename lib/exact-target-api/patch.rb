module ET
  class Patch < ET::Constructor
    def initialize(authStub, objType, props = nil)
      @results = []
      begin
        authStub.refreshToken
        if props.is_a? Array
          obj = { 'Objects' => [] }
          props.each do |p|
            obj['Objects'] << p.merge('@xsi:type' => 'tns:' + objType)
          end
        else
          obj = { 'Objects' => props.merge('@xsi:type' => 'tns:' + objType) }
        end

        response = authStub.auth.call(:update, message: obj)

      ensure
        super(response)
        if @status
          @status = false if @body[:update_response][:overall_status] != 'OK'
          if !@body[:update_response][:results].is_a?(Hash)
            @results += @body[:update_response][:results]
          else
            @results.push(@body[:update_response][:results])
          end
        end
      end
    end
  end
end
