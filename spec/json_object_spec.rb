require 'spec_helper'

describe JsonMessage::JsonObject do
  subject(:object) {
    JsonMessage::JsonObject.new(snake_key:{'space key'=>[1]})
  }

  it "camel-cases json keys" do
    json = object.to_s
    json.should =~ /snakeKey/
    json.should =~ /spaceKey/
  end

  it "parses json to ruby structure" do
    json = object.to_s
    obj  = JsonMessage::JsonObject.parse(json)
    obj[:snake_key][:space_key][0].should == 1

    obj  = JsonMessage::JsonObject.new(json, key_style: :camel)
    obj.value[:snakeKey][:spaceKey][0].should == 1
  end

end
