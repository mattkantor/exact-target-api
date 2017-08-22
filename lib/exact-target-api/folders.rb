module ET
  class Folders < ET::BaseObject
    def initialize(client)
      @client = client
    end

    def find_or_create(name, type, description = '', parent_folder_id = nil, options = {})
      if (folder_id = find(name, type))
        folder_id
      else
        parent_folder_id ||= default_by_type(type)
        create(name, type, description, parent_folder_id, options)
      end
    end


    def find(name, type)
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
          'Value' => type
        }
      }
      res = folder.get(props, filter)

      res.results[0][:id] if res.results[0]
    end

    def default_by_type(type)
      folder = ET::Folder.new
      folder.client = @client
      props = ["ID"]
      filter = {
        'LeftOperand' => {
          'Property' => 'ParentFolder.ID',
          'SimpleOperator' => 'equals',
          'Value' => '0'
        },
        'LogicalOperator' => 'AND',
        'RightOperand' => {
          'Property' => 'ContentType',
          'SimpleOperator' => 'equals',
          'Value' => type
        }
      }
      res = folder.get(props, filter)

      res.results[0][:id] if res.results[0]
    end


    def create(name, type, description = '',parent_folder_id = 0, options = {})
      stringify_keys!(options)

      folder = ET::Folder.new
      folder.client = @client
      data = {
        "CustomerKey" => name,
        "Name" => name,
        "ContentType"=> type,
        "ParentFolder" => {"ID" => parent_folder_id, "IDSpecified" => 0},
        "Description" => description
      }.merge(options)

      res = folder.post(data)
      if res.results[0] && (id = res.results[0][:new_id]).to_i > 0
        id
      end
    end

  end
end
