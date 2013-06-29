module ET
  class Folders < ET::BaseObject
    def initialize(client)
      @client = client


    end

    def find_or_create(name, parent_folder_id, description = '', options = {})
      if (folder_id = find(name))
        folder_id
      else
        create(name, parent_folder_id, description, options)
      end
    end


    def find(name)
      folder = ET::Folder.new
      folder.client = @client
      props = ["ID"]
      filter = {
        'LeftOperand' => {
          'Property' => 'Name',
          'SimpleOperator' => 'equals',
          'Value' => name
        },
        'LogicalOperator' => 'AND',
        'RightOperand' => {
          'Property' => 'ContentType',
          'SimpleOperator' => 'equals',
          'Value' => 'EMAIL'
        }
      }
      res = folder.get(props, filter)

      res.results[0][:id] if res.results[0]
    end


    def create(name, parent_folder_id, description = '', options = {})
      stringify_keys!(options)

      folder = ET::Folder.new
      folder.client = @client
      data = {
        "CustomerKey" => name,
        "Name" => name,
        "ContentType"=> "EMAIL",
        "ParentFolder" => {"ID" => parent_folder_id},
        "Description" => description
      }.merge(options)

      res = folder.post(data)
      if res.results[0] && (id = res.results[0][:new_id]).to_i > 0
        id
      end
    end

  end
end