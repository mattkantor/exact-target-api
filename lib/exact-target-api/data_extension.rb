module ET
  class DataExtension < ET::CUDSupport
    attr_accessor :columns

    def initialize
      super
      @obj = 'DataExtension'
    end

    def post
      originalProps = @props

      if @props.is_a? Array
        multiDE = []
        @props.each { |currentDE|
          currentDE['Fields'] = {}
          currentDE['Fields']['Field'] = []
          currentDE['columns'].each { |key|
            currentDE['Fields']['Field'].push(key)
          }
          currentDE.delete('columns')
          multiDE.push(currentDE.dup)
        }

        @props = multiDE
      else
        @props['Fields'] = {'Field' => []}

        @columns.each do |key|
          @props['Fields']['Field'].push(key)
        end
      end

      obj = super
      @props = originalProps
      obj
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

      def initialize
        super
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
        currentProp = {}
        ## FIX THIS
        if @props.is_a? Array then
=begin
				multiRow = []
				@props.each { |currentDE|

					currentDE['columns'].each { |key|
						currentDE['Fields'] = {}
						currentDE['Fields']['Field'] = []
						currentDE['Fields']['Field'].push(key)
					}
					currentDE.delete('columns')
					multiRow.push(currentDE.dup)
				}

				@props = multiRow
=end
        else
          currentFields = []

          @props.each { |key,value|
            currentFields.push({"Name" => key, "Value" => value})
          }
          currentProp['CustomerKey'] = @CustomerKey
          currentProp['Properties'] = {}
          currentProp['Properties']['Property'] = currentFields
        end

        obj = ET::Post.new(@authStub, @obj, currentProp)
        @props = originalProps
        obj
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
          if @CustomerKey.nil? && @Name.nil?
            raise 'Unable to process DataExtension::Row request due to CustomerKey and Name not being defined on ET::DatExtension::row'
          else
            de = ET::DataExtension.new
            de.authStub = @authStub
            de.props = ["Name","CustomerKey"]
            de.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => @Name}
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
          if @CustomerKey.nil? && @Name.nil?
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