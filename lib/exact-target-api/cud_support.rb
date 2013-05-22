module ET
  class CUDSupport < ET::GetSupport
    def initialize
      super
    end

    def post(data)
      ET::Post.new(@client, @obj, data)
    end

    def patch(data)
      ET::Patch.new(@client, @obj, data)
    end

    def delete(data)
      ET::Delete.new(@client, @obj, data)
    end
  end
end