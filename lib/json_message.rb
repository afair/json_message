require "json_message/version"
require "json_message/request"

module JsonMessage
 
  #  request = JsonMessage.new("Account", 123, "suspend", *args)
  def self.new(resource=nil, id=nil, method=nil, *args)
    JsonMessage::Request.new(resource:resource, id:id, method:method, args:args)
  end
end
