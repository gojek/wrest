[![Build Status](https://travis-ci.org/gojektech/wrest.svg?branch=master)](https://travis-ci.org/gojektech/wrest)

# Wrest 2.2.0

(c) Copyright 2009-2016 [Sidu Ponnappa](http://twitter.com/ponnappa). All Rights Reserved.

Wrest is a ruby REST/HTTP client library. It is currently in use at substantial scale across all Ruby/JRuby systems at [GO-JEK](https://twitter.com/GojekTech).

* Allows you to pick your Ruby: use CRuby or JRuby
* Supports RFC 2616 based [caching](https://github.com/kaiwren/wrest/blob/caching/Caching.markdown)
* Async http calls using Threads (truly useful only on JRuby due to [GIL](https://en.wikipedia.org/wiki/Global_interpreter_lock) limitations on CRuby) or EventMachine
* Allows you to quickly build object oriented wrappers around any web service
* Is designed to be used as a library, not just a command line REST client (fewer class/static methods, more object oriented)
* Is spec driven, strongly favours immutable objects and avoids class methods and setters making it better suited for use as a library, especially in multi-threaded environments
* Provides convenient HTTP wrappers, redirect handling, serialisation, deserialisation and xpath based lookup

To receive notifications whenever new features are added to Wrest, please subscribe to my [twitter feed](http://twitter.com/ponnappa).

## Examples

For Facebook, Twitter, Delicious, GitHub and other API examples, see http://github.com/c42/wrest/tree/master/examples

### Basic Http Calls

#### GET

* Basic API calls

    ```
    # Works with json and xml out of the box
    # See lib/wrest/components/translators to add other formats
    
    'https://api.github.com/repos/c42/wrest/issues'.to_uri.get.deserialize
    ```

* Timeout support

    ```
    'https://api.github.com/repos/c42/wrest/issues'.to_uri(timeout: 5).get.body
    ```

* Redirect support

    ```
    'http://google.com'.to_uri(follow_redirects: false).get

    'http://google.com'.to_uri(follow_redirects_limit: 1).get
    ```

  :follow_redirects_limit defaults to 5 if not specified.

* Deserialise with XPath filtering

    ```
    ActiveSupport::XmlMini.backend = 'REXML'

    'http://twitter.com/statuses/public_timeline.xml'.to_uri.get.deserialise(
                                                  xpath: '//user/name/text()'
                                                )
    ```

* More complex request with parameters and a custom deserialiser

    ```
    'api.openweathermap.org/data/2.5/weather'.to_uri.get(
                  lat: 35,
                  lon: 139
                  ).deserialise_using(
                  Wrest::Components::Translators::Xml
                )
    ```

* Basic HTTP auth and URI extensions using Wrest::Uri#[]

    ```
    base_uri = 'https://api.del.icio.us/v1'.to_uri(username: 'kaiwren', password: 'fupupp1es')
    bookmarks = base_uri['/posts/get'].get.deserialise
    ```

* Detailed debugging and logging (NOT FOR USE IN PRODUCTION! SEE API DOCS!)

    ```
    'https://api.github.com/repos/c42/wrest/issues'.to_uri(detailed_http_logging: $stdout).get.deserialize
    ```

#### POST

* Regular, vanilla Post with a body and headers

    ```
    'http://my.api.com'.to_uri.post('YAML encoded body', 'Content-Type' => 'text/x-yaml')
    ```

* Form encoded post

    ```
    'https://api.del.icio.us/v1/posts/add'.to_uri(
             username: 'kaiwren', password: 'fupupp1es'
          ).post_form(
             url: 'http://blog.sidu.in/search/label/ruby',
             description: 'The Ruby related posts on my blog!',
             extended: "All posts tagged with 'ruby'",
             tags: 'ruby hacking'
          )
    ```

* Multipart posts

    ```
   'http://imgur.com/api/upload.xml'.to_uri.post_multipart(
     image: UploadIO.new(File.open(file_path), "image/png", file_path),
     key: imgur_key
    ).deserialise
    ```

Note: To enable Multipart support, you'll have to explicitly require 'wrest/multipart', which depends on the multipart-post gem.

#### DELETE

To delete a resource:

```
 'https://api.del.icio.us/v1/posts/delete'.to_uri(
                                              username: 'kaiwren',
                                              password: 'fupupp1es'
                                            ).delete(
                                              url: 'http://c2.com'
                                            )
```


### Caching

Wrest supports caching with the following pluggable back-ends:
  - Hash
  - Memcached
  - Redis

#### Hash

Use the following method to enable caching for all requests, and set Hash as the default cache store.
Note: Hash should NEVER be used in a production environment. It is unbounded and will keep increasing in size.

```
    Wrest::Caching.default_to_hash!
    c42 = 'http://c42.in'.to_uri.get
```

To use Hash as a cache store in an explicit request (without setting hash as default), use the following API:

```
    r1 = "http://c42.in".to_uri.using_hash.get
```

#### Memcached

A Memcached based caching back-end is available in Wrest. You can get instructions on how to install Memcached on your system [here](http://code.google.com/p/memcached/wiki/NewInstallFromPackage).
The Dalli gem is used by Wrest to interface with Memcached. Install dalli using 'gem install dalli'.

Use the following method to enable caching for all requests, and set Memcached as the default back-end.

```
    Wrest::Caching.default_to_memcached!
```

To use Memcached as a cache store in an explicit request (without setting memcached as default), use the following API:

```
    Wrest::Caching.enable_memcached
    r2 = "http://c42.in".to_uri.using_memcached.get
```

#### Redis

Wrest also supports a Redis based caching back-end. Follow the guide [here](http://redis.io/topics/quickstart) to install Redis in your system.
It uses [redis-rd](https://github.com/redis/redis-rb) to interface with Redis. Install redis-rb using `gem install redis`.

Use the following method to enable caching for all requests, and set Redis as the default back-end.

```
    Wrest::Caching.default_to_redis!
```

To use Redis as a cache store in an explicit request (without setting redis as default), use the following API:

```
    Wrest::Caching.enable_redis
    r3 = "http://c42.in".to_uri.using_redis.get
```

A detailed writeup regarding caching as defined by RFC 2616, and how Wrest implements caching is at [Wrest Caching Doc](https://github.com/c42/wrest/blob/master/Caching.markdown)

You can create your own back-ends for Wrest caching by implementing the interface implemented in https://github.com/c42/wrest/blob/master/lib/wrest/caching/redis.rb

To explicitly disable caching for specific requests:

```
    "http://c42.in".to_uri.disable_cache.get
```

### Callbacks

#### Uri level callbacks

You can define a set of callbacks that are invoked based on the http codes of the responses to any requests on a given uri.

```
  "http://google.com".to_uri(callback: {
              200      => lambda {|response| Wrest.logger.info "Ok." },
              400..499 => lambda {|response| Wrest.logger.error "Invalid. #{response.body}"},
              300..302 => lambda {|response| Wrest.logger.debug "Redirected. #{response.message}" }
            }).get
```

#### Per request callbacks

You can also define callbacks that are invoked based on the http code of the response to a particular request.

```
  "http://google.com".to_uri.get do |callback|
    callback.on_ok do |response|
      Wrest.logger.info "Ok."
    end

    callback.on(202) do |response|
      Wrest.logger.info "Accepted."
    end

    callback.on(200..206) do |response|
      Wrest.logger.info "Successful."
    end
  end
```

Please note that Wrest is a synchronous library. All requests are blocking, and will not return till the request is completed and appropriate callbacks executed.

### Asynchronous requests

Asynchronous requests are non-blocking. They do not return a response and the request is executed on a separate thread. The only way to access the response
while using asynchronous request is through callbacks.

Asynchronous requests support pluggable backends. The default backend used for asynchronous requests is ruby threads, which is only reliable when using JRuby.

```
  "http://c42.in".to_uri.get_async do |callback|
    callback.on_ok do |response|
      Wrest.logger.info "Ok."
    end
  end

  # Wait until the background threads finish execution before letting the program end.
  Wrest::AsyncRequest.wait_for_thread_pool!
```

You can change the default to eventmachine or to threads.

```
  Wrest::AsyncRequest.default_to_em!
```
or
```
  Wrest::AsyncRequest.default_to_threads!
```

You can also override the default on Uri objects.

```
  "http://c42.in".to_uri.using_em.get_async do |callback|
    callback.on_ok do |response|
      Wrest.logger.info "Ok."
    end
  end
```

You can decide which AsyncBackend to use at runtime through to `to_uri`'s options hash.

```
  "http://c42.in".to_uri(asynchronous_backend: ThreadBackend.new(number_of_threads)).get_async do |callback|
    callback.on_ok do |response|
      Wrest.logger.info "Ok."
    end
  end
```


### Other useful stuff

#### Hash container with ActiveResource-like semantics

Allows any class to hold an attributes hash, somewhat like ActiveResource. It also supports several extensions to this base fuctionality such as support for typecasting attribute values. See examples/twitter.rb and examples/wow_realm_status.rb for more samples.

Example:

```
 class Demon
   include Wrest::Components::Container

   always_has       :id
   typecast         :age          =>  as_integer,
                    :chi          =>  lambda{|chi| Chi.new(chi)}

   alias_accessors  :chi => :energy
 end

 kai_wren = Demon.new('id' => '1', 'age' => '1500', 'chi' => '1024', 'teacher' => 'Viss')
 kai_wren.id       # => '1'
 kai_wren.age      # => 1500
 kai_wren.chi      # => #<Chi:0x113af8c @count="1024">
 kai_wren.energy   # => #<Chi:0x113af8c @count="1024">
 kai_wren.teacher  # => 'Viss'
```

#### Opt-out of core extensions

Uncomfortable with extending `String` to add `to_uri`? Simply do

```
 gem "wrest", :require => "wrest_no_ext"
```

in your Gemfile. You can now do `Uri.new('http://localhost')` to build Uris.

### Logging

The Wrest logger can be set and accessed through Wrest.logger and is configured by default to log to STDOUT. If you're using Wrest in a Rails application, you can configure logging by adding a config/initializers/wrest.rb file with the following contents :

```
  Wrest.logger = Rails.logger
```

Every request and response is logged at level `debug`.

Here is an sample request log message:
```
<- (POST 515036017 732688777 2010) http://localhost:3000/events.json
```

The request log consists of request type (POST), request hash (515036017), connection hash (732688777), thread id (2010), URI (http://localhost:3000/events.json)

Here is a sample response log message:
```
-> (POST 515036017 732688777 2010) 200 OK (0 bytes 0.01s)
```
The response log consists of request type that generated the response (POST), hash of the request that generated the response (515036017), hash of the connection (732688777), thread id (2010), status (200 OK), response body length (0 bytes) and time taken (0.01)s.

The thread id, request hash and connection hashes are used to track requests and their corresponding responses when using asynchronous requests and/or http connection pooling.

Detailed http debug logging can be turned on like so (DO NOT USE IN PRODUCTION! SEE API DOCS.):

    ```
    'https://api.github.com/repos/c42/wrest/issues'.to_uri(detailed_http_logging: $stdout).get.deserialize
    ```


### Json Backend

Wrest uses the multi_json gem to manage Json backends, allowing it to play nice with Rails 3.1. To change the backend used, you can do the following:

```
  MultiJson.engine = :json_gem
```

For more information, look up the [multi_json](http://github.com/intridea/multi_json) documentation.

### Build

Standard options are available and can be listed using `rake -T`. Use rake:rcov for coverage and rake:rdoc to generate documentation. The link to the continuous integration build is over at the C42 Engineering [open source](http://c42.in/open_source) page.

## Documentation

Wrest RDocs can be found at http://wrest.rubyforge.org

## Roadmap

Features that are planned, in progress or already implemented are documented in the [CHANGELOG](http://github.com/kaiwren/wrest/tree/master/CHANGELOG) starting from version 0.0.8.

## Installation

The source is available at git://github.com/kaiwren/wrest.git

To install the Wrest gem, do `(sudo) gem install wrest`.

Wrest is currently available as a gem for for Ruby and JRuby.

### Shell

You can launch the interactive Wrest shell by running bin/wrest if you have the source or invoking `wrest` from your prompt if you've installed the gem.

```
  $ wrest
  >> y 'http://twitter.com/statuses/public_timeline.json'.to_uri(timeout: 5).get.deserialise
```

### Testing

Start the Sinatra test server for functional test. The dependencies for the test app are managed separately by a Gemfile under spec/sample_app.

To start the sample application:

```
  cd spec/sample_app
  bundle install
  bundle exec rake  # runs sample app on port 3000
```

Start a memcached daemon/process on port 11211 and redis on 6379 (both default ports)

```
  brew install memcached
  brew install redis
  brew services start memcached
  brew services start redis
```

Run the tests in a different terminal:

```
  # Run the normal test suite.
  bundle exec rake

  # Runs the functional test suite.
  bundle exec rake rspec:functional
```

## Contributors

* Sidu Ponnappa : [kaiwren](http://github.com/kaiwren)
* Niranjan Paranjape : [achamian](http://github.com/achamian)
* Aakash Dharmadhkari : [aakashd](http://github.com/aakashd)
* Srushti : [srushti](http://github.com/srushti)
* Preethi Ramdev : [preethiramdev](http://github.com/preethiramdev)
* Nikhil Vallishayee : [nikhilvallishayee](http://github.com/nikhilvallishayee)
* Jacques Crocker : [railsjedi](http://github.com/railsjedi)
* Jasim A Basheer: [jasim](http://github.com/jasim)
* Arvind Laxminarayan: [ardsrk](http://github.com/ardsrk)
