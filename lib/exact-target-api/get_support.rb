module ET
  class GetSupport < ET::BaseObject
    attr_accessor :filter

    def initialize
      super
    end

    def get(data = nil, filter = nil)
      obj = ET::Get.new(@client, @obj, data, filter)
      @lastRequestID = obj.request_id
      obj
    end

    def info
      ET::Describe.new(@client, @obj)
    end

    def getMoreResults
      ET::Continue.new(@client, @lastRequestID)
    end
  end
end