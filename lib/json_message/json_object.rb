require 'json'
module JsonMessage
  ##############################################################################
  # JsonObject for Ruby<->JSON conversions, Handles
  #
  # * Key names to JSON camelCase conventions
  # * JSON to Ruby keys as snake_case
  # * Sanitizes keys for JSON
  #
  # Usage:
  #
  # obj         = JsonMessage::JsonObject.new(structure)
  # json_string = obj.to_s
  # structure   = JsonMessage::JsonObject.parse(json_string)
  # obj         = JsonMessage::JsonObject.new(json_string, key_style: :camel)
  # structure   = obj.value
  ##############################################################################

  class JsonObject
    attr_accessor :value

    def initialize(obj, options={})
      @options = options
      if obj.is_a?(String)
        self.value = parse(obj)
      else
        self.value = obj
      end
    end

    def to_s
      JsonObject.json_structure(value).to_json
    end

    alias :to_json :to_s

    def parse(json)
      self.value = JsonObject.ruby_structure(JSON.parse(json), @options)
    end

    def self.parse(json_string, opt={})
      ruby_structure(JSON.parse(json_string), opt)
    end

    def self.json_structure(obj)
      case obj
      when Hash
        o = Hash.new
        obj.each do |k,v|
          o[camel_case(k)] = json_structure(v)
        end
      when Array
        o = Array.new
        obj.each do |v|
          o.push(json_structure(v))
        end
      when Numeric
        o = obj
      else
        o = obj.to_s
      end
      o
    end

    def self.ruby_structure(obj, opt={})
      case obj
      when Hash
        o = Hash.new
        obj.each do |k,v|
          o[key_style(k, opt[:key_style]).to_sym] = ruby_structure(v, opt)
        end
      when Array
        o = Array.new
        obj.each do |v|
          o.push(ruby_structure(v, opt))
        end
      when Numeric
        o = obj
      else
        o = obj.to_s
      end
      o
    end

    def self.key_style(name, style)
      case style
      when nil, :snake
        snake_case(name)
      when :camel
        camel_case(name)
      else
        name
      end
    end

    def self.camel_case(name)
      name.to_s.gsub(/\W/, '_').gsub(/(_\w)/) { |s| s[1].upcase }
    end

    def self.snake_case(name)
      name.to_s.gsub(/([[:lower:]][[:upper:]])/) { |s| s[0] + "_" + s[1].downcase }
    end

  end
end
