require 'base64'

module JsonMessage
  # Translates a Request into HTTP terms
  class HttpRequestBuilder
    def initialize(request, options={})
      @request = request
      @options = options
    end

    def url
      @url = @request.resource

      if @options.has_key?(:base)
        @url = @options[:base] + @url
      end

      if @request.id
        @url += '/' unless @url[-1] == '/'
        @url += @request.id.to_s
      end
      @url
    end

    def headers
      @headers = {'Content-Type'=>'application/json; charset=UTF-8'}
      @headers['Accept'] = 'application/json'
      @headers['Accept-Charset'] = 'UTF-8'
      authorization_header
      @headers
    end

    def authorization_header
      return @options[:authorization] if @options.has_key?(:authorization)
      auth = @request.authentication
      return unless auth

      h = case auth[:method].to_sym
      when :password
         password_authentication(auth)
      when :key
         key_authentication(auth)
      end

      @headers['Authorization'] = h
    end

    def password_authentication(auth)
      a = Base64.encode64(auth[:user] + ':' + auth[:password]).chomp
      "Basic #{a}"
    end

    def key_authentication(auth)
      #"Basic " + Base64.encode64(auth[:key])
      "apikey " + auth[:key]
    end

  end
end
