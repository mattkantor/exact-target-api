module ET
  class List
    class Subscriber < ET::GetSupport
      def initialize
        super
        @obj = 'ListSubscriber'
      end
    end
  end
end