require 'uuid'
require 'json'
################################################################################
# response = {
#   meta: {
#     version:        "",
#     id:             "uuid",
#     status:         "success|error|exception|defer",
#     headers:        {status:200, message:"200 Ok", location:"", $header:""},
#     execution:      {mode:"async|block|reactor", priority:50
#                      at:0, by:0, attempts:0, timeout=0
#                      requested:0, started:0, completed=>0, duration:0,
#                      transactions:0, successes:0, errors:0, cost:0 }
#     pagination:     {page:1, size:10, pages:10, records:100}
#     message:        "",
#     errors:         {field:"", "messsage":count }
#   },
#   $dataName:        $value,
#   links:            { self:"url", all:"url", page:"url",
#                       first:"url", previous:"url", next:"url", last:"url",
#                       $association:"url" }
# }
################################################################################
# statuses: success:  completed without errors
#           error:    completed with application errors (not retried)
#           defer:    could not complete request at this time (resource unavailable)
#           fail:     exceptional condition encountered or defer timeout reached.
################################################################################
module JsonMessage
  class Response

    # Params: hash of optional parts:
    #   meta:{}, # status, message, errors here or on base
    #   status:"sucess|error|exception|defer",
    #   message:"User message",
    #   errors:{"field"=>"Error Message"}
    #   and any result key/value pairs (post:{row}, links:{info}
    def initialize(params={})
      setup_meta(params)
      @d.merge!(params)
    end

  private

    def setup_meta(params)
      @d = {meta:params.delete(:meta) || {}}
      @d[:meta].merge!(
        status:    params.delete(:status) || 'success',
        message:   params.delete(:message)|| '',
        errors:    params.delete(:errors) || {},
        execution: {}
      )
      if r = params.delete(:request)
        @d[:meta][:id]        ||= r.request_id
        @d[:meta][:execution] ||= r.execution
        @d[:meta][:execution][:completed] ||= Time.now.to_f
      end
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

    def pagination
      @d[:meta].fetch(:pagination, {})
    end

    # {page:1, size:10, limit:1000, items:123}
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

    def to_s
      JsonMessage::JsonObject.new(@d).to_s
    end

    alias :to_json :to_s

    def success?
      @d[:meta][:status] == 'success'
    end

  end
end
