ExactTarget API wrapper
=====================

Usage example:

```ruby
require 'rubygems'
require 'bundler/setup'
require 'exact-target-api'

config = {
  clientid: 'xxxxxx',
  clientsecret: 'yyyyyy',
  appsignature: 'zzzzzz' # Optional
}

# All optional
options = {
  debug: false,
  wsdl: true,
  jwt: params[:jwt]
}

client = ET::Client.new(config, options)


list_name = "email test"
data_extension_name = "data_extension test"
emails = (1..25).map { |c| "email_#{c}@gmail.com" }

# @client.folders.find_or_create(name, type, description)

data_extension_folder_id = client.folders.find_or_create('BriteVerify', 'DATAEXTENSION', 'BriteVerify dataextension folder')
# Will create or get folder

data_extension = client.data_extension
data_extension.props = { "Name" => data_extension_name, 'CategoryID' => data_extension_folder_id }
data_extension.columns = [ {"Name" => "Email", "FieldType" => "EmailAddress", "IsRequired" => "true"} ]
data_extension.post
# Will create data extension

data_extension_row = client.data_extension_row(name: data_extension.name)
data_extension_row.props = emails.map { |e| { 'Email' => e } }
data_extension_row.post
# Will create batch rows


list_folder_id = client.folders.find_or_create('BriteVerify', 'LIST', 'BriteVerify list folder')
# Will create or get folder

list = client.list
list.props = { 'ListName' => list_name, 'Category' => list_folder_id }
list.post
# Will create email list

subscribers = client.subscriber(list.id)
subscribers.props = emails.map { |e| { 'EmailAddress' => e } }
subscribers.post
# Will create batch subscribers

```
