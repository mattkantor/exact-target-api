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
    # {ListName: "NewListName", Description: "This list was created with the RubySDK", Type: "Private"}
    def post
      response = super(@props)
      @list_id = response.results[0][:new_id]
      response
    end

    def create(params)
      stringify_keys!(params)
      if (folder_id = params.delete('folder_id'))
        params['CategoryID'] = folder_id
      end
      res = post(params)
      assign_values(res)
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
