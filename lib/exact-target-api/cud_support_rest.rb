module ET
  class CUDSupportRest < ET::GetSupportRest
    def initialize
      super
    end

    def post
      completeURL = @endpoint

      if @props and @props.is_a? Hash then
        @props.each do |k,v|
          if @urlProps.include?(k) then
            completeURL.sub!("{#{k}}", v)
          end
        end
      end

      @urlPropsRequired.each do |value|
        if !@props || !@props.has_key?(value) then
          raise "Unable to process request due to missing required prop: #{value}"
        end
      end

      # Clean Optional Parameters from Endpoint URL first
      @urlProps.each do |value|
        completeURL.sub!("/{#{value}}", "")
      end

      ET::PostRest.new(@authStub, completeURL, @props)
    end

    def patch
      completeURL = @endpoint
      # All URL Props are required when doing Patch
      @urlProps.each do |value|
        if !@props || !@props.has_key?(value) then
          raise "Unable to process request due to missing required prop: #{value}"
        end
      end

      if @props and @props.is_a? Hash then
        @props.each do |k,v|
          if @urlProps.include?(k) then
            completeURL.sub!("{#{k}}", v)
          end
        end
      end

      ET::PatchRest.new(@authStub, completeURL, @props)
    end

    def delete
      completeURL = @endpoint
      # All URL Props are required when doing Patch
      @urlProps.each do |value|
        if !@props || !@props.has_key?(value) then
          raise "Unable to process request due to missing required prop: #{value}"
        end
      end

      if @props and @props.is_a? Hash then
        @props.each do |k,v|
          if @urlProps.include?(k) then
            completeURL.sub!("{#{k}}", v)
          end
        end
      end

      ET::DeleteRest.new(@authStub, completeURL)
    end
  end
end