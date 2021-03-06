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

  it "generates a response" do
    r = request.response
    r.class.should == JsonMessage::Response
    r.success?.should == true
  end
end
