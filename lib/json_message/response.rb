require 'uuid'
require 'json'
################################################################################
# response = {
#   meta: {
#     version:        "",
#     jobId:          "uuid",
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
    def initialize(params={})
      @d = params
      setup_meta
      setup_job(params.delete(:request))
      setup_execution
    end

  private

    def setup_meta(params)
      @d[:meta]          ||= params.delete(:meta) || {}
      @d[:meta][:status] ||= 'success'
      @d[:meta][:message]||= ''
      @d[:meta][:errors] ||= {}
    end

    def setup_job(request)
      @d[:meta][:job_id]    = request.request_id
      @d[:meta][:execution] = request.execution
    end

    def setup_execution
      @d[:meta][:execution] ||= {}
      @d[:meta][:execution][:requested] ||= Time.now.to_f
      @d[:meta][:execution][:started]   ||= Time.now.to_f
      @d[:meta][:execution][:completed] ||= Time.now.to_f
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
      @d.to_json
    end

  end
end
