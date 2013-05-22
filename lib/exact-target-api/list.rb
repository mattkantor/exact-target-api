module ET
  class List < ET::CUDSupport
    attr_reader :list_id, :code, :message, :status

    def initialize(client)
      super()
      @obj = 'List'
      @client = client
    end

    def id
      @list_id
    end

    # Example:
    # {"ListName" => NewListName, "Description" => "This list was created with the RubySDK", "Type" => "Private" }
    def create(params)
      stringify_keys!(params)
      res = post(params)
      assign_values(res)
      self
    end

    def update(params)
      stringify_keys!(params)
      data = params.merge('ID' => @list_id)

      res = patch(data)

      puts "[DEBUG] List update: #{res.inspect}"

      raise('implement me')

      self
    end

    def find(id)
      props = ["ID", "PartnerKey", "CreatedDate", "ModifiedDate", "Client.ID", "Client.PartnerClientKey", "ListName", "Description", "Category", "Type", "CustomerKey", "ListClassification", "AutomatedEmail.ID"]
      filter = {'Property' => 'ID', 'SimpleOperator' => 'equals', 'Value' => id.to_s}
      res = get(props, filter)

      assign_values(res)

      self
    end

    def destroy(id)
      delete('ID' => id.to_s)
    end

    def subscriber
      ET::Subscriber.new(@client, @list_id)
    end

    private

    def assign_values(res)
      if (r = res.results[0])
        @list_id = r[:new_id] || r[:id]
      else
        @list_id = nil
      end
      @code = res.code.to_i
      @message = res.message.to_s
      @status = res.status
    end
  end
end