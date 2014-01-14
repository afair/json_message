# JsonMessage

JSON Message provides a generic Request/Response message passing structure
implemented as JSON. Use it for communication between systems,
processes, message queues, and anywhere where an extensible message
structure is needed. It does not assume all requests run over HTTP.

Influenced by JSON-API, JSON-RPC, HAL/HATEOS, SOAPjr, JSON Patch/Rocket,
and others. 

## Installation

Add this line to your application's Gemfile:

    gem 'json_message'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_message

## Usage

Create a Request Message. Specify only what you need to send

    request = JsonMessage.new("Account", 123, "suspend", *args)
    # or ...
    request = JsonMessage::Request(meta:{id:"UUID"}, 
                resource:"Account", id:123, method:"suspend",
                args:[], options:{})

That request object can be executed synchonously or asynchonously do
whatever service in your system architecture requires.

* HTTP - Simple HTTP Requests
* REST - HTTP Requests in a standard REST format
* SOAP - Without WS-*
* Message Queue - Redis, AMQP, PostgreSQL Pub-Sub, etc.
* XMPP - Or other messaging protocols
* RPC - Remote Procedure Call
* XHR (XmlHttpRequest) from browsers
* Distributed Processing - Drb, etc.

Here, a "resource" is whatever you like it to be, a REST-ful URL, a
queue name, or system name. Everything is meant to be optional, so you
may not even need it.

The "method" can refer to a HTTP verb, or a method name on a class or
command name.

The "id" refers to any specific item identifier if known.

The "args" are like the arguments to the method call. If you are sending
it as an HTTP request, this would hold the list of bodies (form data,
files, etc.). 

The request can be used in different paradigms and service types.

    Resource.find(id).method(*args)           # Object-Oriented
    METHOD http://resource/id + [{form-data}] # REST/HTTP
    POST url + {request-params}               # SOAP/HTTP
    {method:name,params:[args],id:123}        # JSON-RPC

If a response is returned, it can be generated from the request or on
its own.

    response = request.response('success', 'Okay',
                 post:{title:"Hello"})
    # or...
    response = JsonMessage::Response(
                 meta:{status:'success', message:'Okay'},
                 post:{title:"Hello"})

You can convert the request into HTTP values to send via your favorite
HTTP client library.

    http_request = request.to_http(base:"http://example.com")
    http.headers   #=> {...}
    http.url       #=> http://example.com/accounts/1

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
