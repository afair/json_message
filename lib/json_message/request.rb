require 'uuid'
require 'json'
################################################################################
# request = {
#   meta: {
#     id:             "uuid",
#     request:        "queue://$queuename | http://url | mailto://email rpc://url ...",
#     response:       "queue://$queuename | http://url | mailto://email rpc://url ...",
#     execution:      {mode:"async|block|evented|promise", priority:50
#                      at:0, by:0, attempts:0, timeout=0 requested:0 }
#     client:         "",
#     envelope:       {mailFrom:"", rcptTo: []} // SMTP, ENV, or other context
#     authentication: {method:"password", user:"name", password:"secret"},
#     pagination:     {page:1, size:10, limit:1000},
#   },
#   resource:$jobName, id:$recordId, method:"process", args:[], options:{}, raw:""
# }
################################################################################
module JsonMessage
  class Request

    # Optional Params key/values:
    #   meta:{},  # with overrides for id, authentication, etc.
    #   pagination:{}, 
    #   envelope:{},
    #   authentication:{},
    #   execution:{}
    def initialize(params={})
      setup_meta(params.delete(:meta))
      self.pagination     = params.delete(:pagination)
      self.envelope       = params.delete(:envelope)
      self.execution      = params.delete(:execution) if params.has_key?(:execution)
      self.authentication = params.delete(:authentication)
      @d.merge!(params)
    end

  private

    def setup_meta(meta=nil)
      @d = {meta:meta||{}}
      @d[:meta].merge!(
              id:        UUID.new.generate,
              client:    client,
              execution: {requested:Time.now.to_f})
    end

    def get_meta(key)
      @d[:meta].fetch(key, {})
    end

    def set_meta(key, params, *allowed)
      return meta.delete(key) if params.nil?
      @d[:meta][key] ||= {}
      if allowed.size > 0
        params.delete_if { |k,v| ! allowed.include?(k) }
      end
      @d[:meta][key].merge!(params)
    end

  public

    # Meta: holds info about the request
    def meta
      @d[:meta]
    end

    def request_id
      get_meta(:id)
    end

    def client
      "JsonMessage::Request"
    end

    # Execution: {mode:"async|block|evented|promise", priority:50
    #          at:0, by:0, attempts:0, timeout=0 requested:0 }
    def execution
      get_meta(:execution)
    end

    def execution=(params)
      set_meta(:execution, params, :mode, :priority, :at, :by, :attempts,
               :timeout, :requested, :started, :completed)
    end

    # Authentication: 
    #   {method:"password", user:"name", password:"secret"}
    #   {method:"key", key:"secret"}
    def authentication
      get_meta(:authentication)
    end

    def authentication=(params)
      set_meta(:authentication, params)
    end

    # Pagination: {page:1, size:10, limit:1000}
    def pagination
      get_meta(:pagination)
    end

    def pagination=(params)
      set_meta(:pagination, params, :page, :size, :limit)
    end

    # Envelope: context of origination request (like SMTP)
    def envelope
      get_meta(:envelope)
    end

    def envelope=(params)
      set_meta(:envelope, params)
    end

    # Response: url/location to send response object
    def response_to
      get_meta(:response)
    end

    def response_to=(url)
      meta[:response] = url
    end

################################################################################

    def resource
      @d.fetch(:resource, nil)
    end

    def resource=(url)
      @d[:resource] = url
    end


    def id
      @d.fetch(:id, nil)
    end

    def id=(id)
      @d[:id] = id
    end


    def args
      @d.fetch(:args, nil)
    end

    def args=(*arr)
      @d[:args] = arr
    end


    def options
      @d.fetch(:options, {})
    end

    def options=(hash)
      @d[:options] = hash
    end


    #alias :omethod :method
    def method
      @d.fetch(:method, nil)
    end

    def method=(m)
      @d[:method] = m
    end

################################################################################

    def to_s
      JsonMessage::JsonObject.new(@d).to_s
    end

    alias :to_json :to_s

    def start
      @d[:meta][:execution][:started]    = Time.now.to_f
      @d[:meta][:execution][:attempts] ||= 0
      @d[:meta][:execution][:attempts]  += 1
    end

    def response(status='success', message='', result={})
      start unless @d[:meta][:execution][:started]
      self.execution = {completed: Time.now.to_f}
      JsonMessage::Response.new(
        { request:self,
          meta:{status:status, message:message}
        }.merge(result))
    end

    def to_http(options={})
      JsonMessage::HttpRequestBuilder.new(self, options)
    end

  end
end
