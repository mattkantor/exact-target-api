module ET
  class Post < ET::Constructor
    def initialize(client, obj_type, props = nil)
      @results = []
      begin
        client.refreshToken
        obj = {}
        obj['Options'] = props.delete('Options') if props.key?('Options')
        obj['Objects'] = props.merge('@xsi:type' => 'tns:' + obj_type)
        response = client.auth.call(:create, message: obj)
      ensure
        super(response)
        if @status
          @status = false if @body[:create_response][:overall_status] != 'OK'
          unless @body[:create_response][:results].nil?
            if !@body[:create_response][:results].is_a?(Hash)
              @results += @body[:create_response][:results]
            else
              @results.push(@body[:create_response][:results])
            end
          end
        end
      end
    end
  end
end
