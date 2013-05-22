module ET
  class TriggeredSend < ET::CUDSupport
    attr_accessor :subscribers

    def initialize
      super
      @obj = 'TriggeredSendDefinition'
    end

    def send
      @tscall = {"TriggeredSendDefinition" => @props, "Subscribers" => @subscribers}
      ET::Post.new(@authStub, "TriggeredSend", @tscall)
    end
  end
end