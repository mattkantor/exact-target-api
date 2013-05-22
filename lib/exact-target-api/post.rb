module ET
  class Post < ET::Constructor
    def initialize(client, objType, props = nil)
      @results = []

      begin
        client.refreshToken

        obj = {
          'Objects' => props,
          attributes!: {'Objects' => {'xsi:type' => 'tns:' + objType}}
        }

        response = client.auth.call(:create, message: obj)

      ensure
        super(response)
        if @status
          if @body[:create_response][:overall_status] != "OK"
            @status = false
          end
          #@results = @body[:create_response][:results]
          if !@body[:create_response][:results].nil?
            if !@body[:create_response][:results].is_a? Hash
              @results = @results + @body[:create_response][:results]
            else
              @results.push(@body[:create_response][:results])
            end
          end
        end
      end
    end
  end
end