require 'spec_helper'

describe JsonMessage::Request do
  subject(:request) {
    JsonMessage::Request.new(resource:"Account", id:123, method:"suspend", args:[1,2,3])
  }

  it 'creates new Request' do
    request.id.should == 123
    request.method.should == 'suspend'
  end

  it "creates json" do
    json = request.to_s
    json.index(%Q("method":"suspend")).should_not == nil
  end

  it "generates a response" do
    r = request.response
    r.class.should == JsonMessage::Response
    r.success?.should == true
  end

end
