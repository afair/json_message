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
* RPC - Remote Procedure Call
* XHR (XmlHttpRequest) from browsers

If a response is returned, it can be generated from the request or on
its own.

    response = request.response('success', 'Okay',
                 post:{title:"Hello"})
    # or...
    response = JsonMessage::Response(
                 meta:{status:'success', message:'Okay'},
                 post:{title:"Hello"})

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
