module ET
  class CreateWSDL
    def initialize(path)
      # Get the header info for the correct wsdl
      response = HTTPI.head(@wsdl)
      if response && response.code >= 200 && response.code <= 400
        header = response.headers
        # Check when the WSDL was last modified
        modifiedTime = Date.parse(header['last-modified'])
        p = wsdl_file(path)
        # Check if a local file already exists
        if File.file?(p) && File.readable?(p) && !File.zero?(p)
          createdTime = File.new(p).mtime.to_date

          # Check if the locally created WSDL older than the production WSDL
          createIt = createdTime < modifiedTime
        else
          createIt = true
        end

        if createIt
          res = open(@wsdl).read
          File.open(p, 'w+') do |f|
            f.write(res)
          end
        end

        @status = response.code
      else
        @status = response.code
      end

    end

    def wsdl_file(path)
      path + '/ExactTargetWSDL.xml'
    end

  end
end