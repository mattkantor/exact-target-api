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


# Create new List
list = client.list.create(
  ListName: "Test-List",
  Description:  "Test List",
  Type: "Private"
)

puts "List ID is #{list.id}"

# Find a List
list2 = client.list.find(list.id)

# Create invalid subscriber
subscriber = client.subscriber.create(email: 'foo@bar.aaaa')
subscriber = client.subscriber.create(email: 'foo@bar.aaaa', list: list)
subscriber = client.subscriber.create(email: 'foo@bar.aaaa', list_id: 12345, name: "Foo Bar")

puts subscriber.code # 200
puts subscriber.status # false
puts subscriber.results # {:status_code=>"Error", :status_message=>"TriggeredSpamFilter", :ordinal_id=>"0", :error_code=>"12002", :new_id=>"0", :object=>{:partner_key=>nil, :object_id=>nil, :email_address=>"foo@bar.aaaa", :lists=>{:partner_key=>nil, :id=>"3488", :object_id=>nil}, :"@xsi:type"=>"Subscriber"}}

# Create valid subscriber
subscriber = client.subscriber.create(email: "RubySDK@bh.exacttarget.com", name: "Foo Bar", Description: "Some text")
puts subscriber.code # 200
puts subscriber.status # true
puts subscriber.results # {:status_code=>"OK", :status_message=>"Created Subscriber.", :ordinal_id=>"0", :new_id=>"24761785", :object=>{:partner_key=>nil, :id=>"24761785", :object_id=>nil, :email_address=>"RubySDK@bh.exacttarget.com", :attributes=>[{:name=>"name", :value=>"Foo Bar"}, {:name=>"Description", :value=>"Some text"}], :"@xsi:type"=>"Subscriber"}}

# Find a  subscriber
subscriber = client.subscriber.find("RubySDK@bh.exacttarget.com")

puts subscriber.status # true
puts subscriber.results	# {:partner_key=>nil, :object_id=>nil, :email_address=>"RubySDK@bh.exacttarget.com", :subscriber_key=>"RubySDK@bh.exacttarget.com", :status=>"Active", :"@xsi:type"=>"Subscriber"}


# Folders
folder_id = client.folders.find 'FolderName'
folder_id = client.folders.create 'FolderName', parent_folder_id, 'Some description'
folder_id = client.folders.find_or_create 'FolderName', parent_folder_id, 'Some description'

list = client.list.create(
  ListName: "...",
  Description:  "...",
  Type: "Private",
  folder_id: folder_id
  # OR
  # CategoryID: folder_id
)



```
