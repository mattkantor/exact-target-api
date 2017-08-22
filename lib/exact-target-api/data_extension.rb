module ET
  class DataExtension < ET::CUDSupport
    attr_accessor :columns, :name

    def initialize(client)
      super()
      @client = client
      @obj = 'DataExtension'
    end

    def get
      super(@props, @filter)
    end

    def post
      originalProps = @props

      if @props.is_a? Array
        # not sure we need this
      else
        @props['Fields'] = {'Field' => @columns}
      end

      response = super @props
      @name = response.results[0][:object][:name]
      @props = originalProps
      response
    end

    def patch
      @props['Fields'] = {}
      @props['Fields']['Field'] = []
      @columns.each { |key|
        @props['Fields']['Field'].push(key)
      }
      obj = super
      @props.delete("Fields")
      obj
    end

    class Column < ET::GetSupport
      def initialize
        super
        @obj = 'DataExtensionField'
      end

      def get

        if props and props.is_a? Array then
          @props = props
        end

        if @props and @props.is_a? Hash then
          @props = @props.keys
        end

        if filter and filter.is_a? Hash then
          @filter = filter
        end

        fixCustomerKey = false
        if filter and filter.is_a? Hash
          @filter = filter
          if @filter.has_key?("Property") && @filter["Property"] == "CustomerKey"
            @filter["Property"]  = "DataExtension.CustomerKey"
            fixCustomerKey = true
          end
        end

        obj = ET::Get.new(@authStub, @obj, @props, @filter)
        @lastRequestID = obj.request_id

        if fixCustomerKey then
          @filter["Property"] = "CustomerKey"
        end

        obj
      end
    end

    class Row < ET::CUDSupport
      attr_accessor :Name, :CustomerKey

      def initialize(client)
        super()
        @client = client
        @obj = "DataExtensionObject"
      end

      def get
        getName
        if props and props.is_a? Array then
          @props = props
        end

        if @props and @props.is_a? Hash then
          @props = @props.keys
        end

        if filter and filter.is_a? Hash then
          @filter = filter
        end

        obj = ET::Get.new(@authStub, "DataExtensionObject[#{@Name}]", @props, @filter)
        @lastRequestID = obj.request_id

        obj
      end

      def post
        getCustomerKey
        originalProps = @props
        if @props.is_a? Array then
          currentProps = @props.map do |currentProp|
            {
              'CustomerKey' => @CustomerKey,
              'Properties' => {
                'Property' => currentProp.map {|key,value| {"Name" => key, "Value" => value}}
              }
            }
          end
        elsif @props.is_a? Hash
          currentProps = {
            'CustomerKey' => @CustomerKey,
            'Properties' => {
              'Property' => @props.map {|key,value| {"Name" => key, "Value" => value}}
            }
          }
        end

        response = super currentProps
        @props = originalProps
        response
      end

      def patch
        getCustomerKey
        currentFields = []
        currentProp = {}

        @props.each { |key,value|
          currentFields.push({"Name" => key, "Value" => value})
        }
        currentProp['CustomerKey'] = @CustomerKey
        currentProp['Properties'] = {}
        currentProp['Properties']['Property'] = currentFields

        ET::Patch.new(@authStub, @obj, currentProp)
      end

      def delete
        getCustomerKey
        currentFields = []
        currentProp = {}

        @props.each { |key,value|
          currentFields.push({"Name" => key, "Value" => value})
        }
        currentProp['CustomerKey'] = @CustomerKey
        currentProp['Keys'] = {}
        currentProp['Keys']['Key'] = currentFields

        ET::Delete.new(@authStub, @obj, currentProp)
      end

      private

      def getCustomerKey
        if @CustomerKey.nil?
          if @Name.nil?
            raise 'Unable to process DataExtension::Row request due to CustomerKey and Name not being defined on ET::DatExtension::row'
          else
            de = ET::DataExtension.new(@client)
            de.props = ["Name", "CustomerKey"]
            de.filter = {'Property' => 'Name','SimpleOperator' => 'equals','Value' => @Name}
            getResponse = de.get
            if getResponse.status && (getResponse.results.length == 1) then
              @CustomerKey = getResponse.results[0][:customer_key]
            else
              raise 'Unable to process DataExtension::Row request due to unable to find DataExtension based on Name'
            end
          end
        end
      end

      def getName
        if @Name.nil?
          if @CustomerKey.nil?
            raise 'Unable to process DataExtension::Row request due to CustomerKey and Name not being defined on ET::DatExtension::row'
          else
            de = ET::DataExtension.new
            de.authStub = @authStub
            de.props = ["Name","CustomerKey"]
            de.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => @CustomerKey}
            getResponse = de.get
            if getResponse.status && getResponse.results.length == 1
              @Name = getResponse.results[0][:name]
            else
              raise 'Unable to process DataExtension::Row request due to unable to find DataExtension based on CustomerKey'
            end
          end
        end
      end
    end
  end
end
