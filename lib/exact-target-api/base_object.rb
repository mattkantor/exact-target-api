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


    def stringify_keys!(params)
      params.keys.each do |key|
        params[key.to_s] = params.delete(key)
      end
      params
    end

    def symbolize_keys!(params)
      params.keys.each do |key|
        params[key.to_sym] = params.delete(key)
      end
      params
    end
  end
end