module ET
  class Subscriber < ET::CUDSupport
    attr_reader :code, :message, :status, :email, :results

    def initialize(client, list_id = nil)
      super()
      @client = client
      @list_id =  list_id
      @obj = 'Subscriber'
    end

    def create(email, params = {})
      props = {'EmailAddress' => email}.merge(params)
      props['Lists'] =  [{'ID' => @list_id.to_s}] if @list_id

      puts "[DEBUG] props: #{props}"

      res = post(props)
      if assign_values(res)
        @email = email
      end

      self
    end

    def find(email)
      @email = email

      props = ["SubscriberKey", "EmailAddress", "Status"]
      filter = {'Property' => 'SubscriberKey', 'SimpleOperator' => 'equals', 'Value' => email}

      res = get(props, filter)
      if assign_values(res)
        @email = email
      end

      self
    end

    def update(params)
      params.merge!('EmailAddress' => @email)

      # TODO ...

    end


    private

    def assign_values(res)
      @code = res.code.to_i
      @message = res.message.to_s
      @status = res.status
      @results = res.results

      p 'Post Status: ' + res.status.to_s
      p 'Code: ' + res.code.to_s
      p 'Message: ' + res.message.to_s
      p 'Result Count: ' + res.results.length.to_s
      p 'Results: ' + res.results.inspect
      res.status
    end


  end
end