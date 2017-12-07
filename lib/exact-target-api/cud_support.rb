module ET
  class CUDSupport < ET::GetSupport
    def initialize
      super
    end

    def post(props)
      ET::Post.new(@client, @obj, props)
    end

    def patch(props)
      ET::Patch.new(@client, @obj, props)
    end

    def delete(props)
      ET::Delete.new(@client, @obj, props)
    end
  end
end
