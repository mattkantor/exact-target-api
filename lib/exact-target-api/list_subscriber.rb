module ET
  class List
    class Subscriber < ET::GetSupport
      def initialize(client)
        super()
        @client = client
        @obj = 'ListSubscriber'
      end
    end
  end
end
