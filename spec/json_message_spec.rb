require 'spec_helper'

describe JsonMessage do
  subject(:request) {
    JsonMessage.new("Account", 123, "suspend", 1, 2, 3)
  }
  it 'should have a version number' do
    JsonMessage::VERSION.should_not be_nil
  end

  it 'creates new Request' do
    request.class.should == JsonMessage::Request
    request.id.should == 123
    request.method.should == 'suspend'
  end

  it "creates json" do
    puts request.to_json
    JSON.parse(request.to_json).class.should == Hash
  end

  it "generates a response" do
    request.response.shoud == JsonMessage::Request
  end
end
