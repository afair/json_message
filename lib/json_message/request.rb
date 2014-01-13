require 'uuid'
require 'json'
################################################################################
# request = {
#   meta: {
#     jobId:          "uuid",
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
    def initialize(params={})
      @d = params
      setup_meta
      setup_execution
    end

  private

    def setup_meta
      @d[:meta]          ||= {}
      @d[:meta][:id]     ||= UUID.new.generate
      @d[:meta][:client] ||= client
    end

    def client
      "JsonMessage::Request"
    end

    def setup_execution
      @d[:meta][:execution] ||= {}
      @d[:meta][:execution][:requested] ||= Time.now.to_f
    end

  public
    def meta
      @d[:meta]
    end


    def request_id
      @d[:meta][:id]
    end

    def execution
      @d[:meta].fetch(:authentication, {})
    end

    # params: {mode:"async|block|evented|promise", priority:50
    #          at:0, by:0, attempts:0, timeout=0 requested:0 }
    def execution=(params)
      @d[:meta][:execution] = params
    end

    def authenication
      @d[:meta].fetch(:authentication, {})
    end

    # {method:"password", user:"name", password:"secret"}
    def authenication=(params)
      @d[:meta][:authentication] = params
    end

    def pagination
      @d[:meta].fetch(:pagination, {})
    end

    def response_to
      @d[:meta].fetch(:response, nil)
    end

    def response_to=(url)
      @d[:meta][:response] = url
    end

    # {page:1, size:10, limit:1000}
    def pagination=(params)
      @d[:meta][:pagination] = params
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

    def to_json
      ## Camelcase keys....
      @d.to_json
    end

    def start
      @d[:meta][:execution][:started]    = Time.now.to_f
      @d[:meta][:execution][:attempts] ||= 0
      @d[:meta][:execution][:attempts]  += 1
    end

    def response(status='success', message='', result={})
      @d[:meta][:execution][:completed]  = Time.now.to_f
      JsonMessage::Response.new({ request:self,
                                  meta:{status:status, message:message}
                                }.merge(result))
    end

  end
end
