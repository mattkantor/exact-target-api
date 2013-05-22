module ET
  class Campaign < ET::CUDSupportRest
    def initialize
      super
      @endpoint = 'https://www.exacttargetapis.com/hub/v1/campaigns/{id}'
      @urlProps = ["id"]
      @urlPropsRequired = []
    end

    class Asset < ET::CUDSupportRest
      def initialize
        super
        @endpoint = 'https://www.exacttargetapis.com/hub/v1/campaigns/{id}/assets/{assetId}'
        @urlProps = ["id", "assetId"]
        @urlPropsRequired = ["id"]
      end
    end
  end
end