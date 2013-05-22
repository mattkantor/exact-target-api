module ET
  class Email < ET::CUDSupport
    def initialize
      super
      @obj = 'Email'
    end
  end
end