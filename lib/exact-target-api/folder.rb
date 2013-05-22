module ET
  class Folder < ET::CUDSupport
    def initialize
      super
      @obj = 'DataFolder'
    end
  end
end