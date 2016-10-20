module ET
  class Subscriber
    class List < ET::CUDSupport
      def initialize(client)
        super()
        @client = client
        @obj = 'SubscriberList'
      end
    end
  end
end
