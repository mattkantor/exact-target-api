module ET
  class GetSupportRest < ET::BaseObject
    attr_reader :urlProps, :urlPropsRequired, :lastPageNumber

    def initialize
      super
    end

    def get(props = nil)
      if props and props.is_a? Hash then
        @props = props
      end

      completeURL = @endpoint
      additionalQS = {}

      if @props and @props.is_a? Hash then
        @props.each do |k,v|
          if @urlProps.include?(k) then
            completeURL.sub!("{#{k}}", v)
          else
            additionalQS[k] = v
          end
        end
      end

      @urlPropsRequired.each do |value|
        if !@props || !@props.has_key?(value) then
          raise "Unable to process request due to missing required prop: #{value}"
        end
      end

      @urlProps.each do |value|
        completeURL.sub!("/{#{value}}", "")
      end

      obj = ET::GetRest.new(@authStub, completeURL,additionalQS)

      if obj.results.has_key?('page')
        @lastPageNumber = obj.results['page']
        pageSize = obj.results['pageSize']
        if obj.results.has_key?('count') then
          count = obj.results['count']
        elsif obj.results.has_key?('totalCount') then
          count = obj.results['totalCount']
        end

        if !count.nil? && count > (@lastPageNumber * pageSize)
          obj.moreResults = true
        end
      end
      obj
    end

    def getMoreResults
      if props and props.is_a? Hash
        @props = props
      end

      originalPageValue = "1"
      removePageFromProps = false

      if !@props.nil? && @props.has_key?('$page')
        originalPageValue = @props['page']
      else
        removePageFromProps = true
      end

      if @props.nil?
        @props = {}
      end

      @props['$page'] = @lastPageNumber + 1

      obj = self.get

      if removePageFromProps then
        @props.delete('$page')
      else
        @props['$page'] = originalPageValue
      end

      obj
    end
  end
end