module ET
  class BaseObject
    attr_accessor :props, :client
    attr_reader :obj, :lastRequestID, :endpoint

    def initialize
      @props = nil
      @filter = nil
      @lastRequestID = nil
      @endpoint = nil
    end
  end
end