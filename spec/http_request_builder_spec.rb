require 'spec_helper'

describe JsonMessage::HttpRequestBuilder do
  subject(:request) {
    JsonMessage.new("/accounts", 123, "suspend", 1, 2, 3)
  }
  subject(:http) do
    r = JsonMessage.new("/accounts", 123, "suspend", 1, 2, 3)
    r.authentication = {method:"key", key:"secret"}
    r.to_http(base:"http://example.com")
  end

  it "builds request" do
    http.url.should == 'http://example.com/accounts/123'
  end

  it "provides headers" do
    p http.headers
    http.headers['Accept'].should == 'application/json'
  end

  it "has authentication" do
    http.headers['Authorization'].should == 'apikey secret'
  end
end
