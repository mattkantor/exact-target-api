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
  appsignature: 'zzzzzz'
}

client = ET::Client.new(config)


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
subscriber = list.subscriber.create('foo@bar.aaaa')

puts subscriber.code # 200
puts subscriber.status # false
puts subscriber.results # {:status_code=>"Error", :status_message=>"TriggeredSpamFilter", :ordinal_id=>"0", :error_code=>"12002", :new_id=>"0", :object=>{:partner_key=>nil, :object_id=>nil, :email_address=>"foo@bar.aaaa", :lists=>{:partner_key=>nil, :id=>"3488", :object_id=>nil}, :"@xsi:type"=>"Subscriber"}}

# Create valid subscriber
subscriber = list.subscriber.create("RubySDKListSubscriber@bh.exacttarget.com")

# Find a  subscriber
subscriber = list.subscriber.find("RubySDKListSubscriber@bh.exacttarget.com")

puts subscriber.status # true
puts subscriber.results	# {:partner_key=>nil, :object_id=>nil, :email_address=>"RubySDKListSubscriber@bh.exacttarget.com", :subscriber_key=>"RubySDKListSubscriber@bh.exacttarget.com", :status=>"Active", :"@xsi:type"=>"Subscriber"}



```
