require 'spec_helper'

describe JsonMessage::Response do
  subject(:request) {
    JsonMessage.new("Account", 123, "suspend", 1, 2, 3)
  }

  subject(:response) {
    request.response('success', 'Okay', data_thing:{id:1})
  }

  it "has a meta id" do
    response.request_id.should == request.request_id
  end

  it "stringifies to json" do
    json = response.to_s
    json.index(%Q("status":"success")).should_not == nil
    json.index(%Q("dataThing")).should_not == nil
  end
  
end
