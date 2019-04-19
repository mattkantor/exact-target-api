module ET
  class CreateWSDL
    def initialize(path)
      # Get the header info for the correct wsdl
      puts "Llama wsdl-lina: #{@wsdl.inspect}"
      puts "Llama path path paths: #{path}"
      response = HTTPI.head(@wsdl)
      puts "MOOSE Response: #{response.inspect}"
      if response && response.code >= 200 && response.code <= 400
        puts "MOOSE Response Headers: #{response.headers.inspect}"
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

    def stringify_keys!(params)
      params.keys.each do |key|
        params[key.to_s] = params.delete(key)
      end
      params
    end

    def symbolize_keys!(params)
      params.keys.each do |key|
        params[key.to_sym] = params.delete(key)
      end
      params
    end
  end
end
