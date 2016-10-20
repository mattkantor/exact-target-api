module ET
  class Delete < ET::Constructor
    def initialize(authStub, obj_type, props = nil)
      @results = []
      begin
        authStub.refreshToken
        if props.is_a?(Array)
          obj = { 'Objects' => [] }
          props.each do |p|
            obj['Objects'] << p.merge('@xsi:type' => 'tns:' + obj_type)
          end
        else
          obj = { 'Objects' => props.merge('@xsi:type' => 'tns:' + obj_type) }
        end
        response = authStub.auth.call(:delete, message: obj)
      ensure
        super(response)
        if @status
          @status = false if @body[:delete_response][:overall_status] != 'OK'
          if !@body[:delete_response][:results].is_a? Hash
            @results += @body[:delete_response][:results]
          else
            @results.push(@body[:delete_response][:results])
          end
        end
      end
    end
  end
end
