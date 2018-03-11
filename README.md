# rails-reverse-proxy

A reverse proxy for Ruby on Rails.

*A reverse proxy accepts a request from a client, forwards it to a server that can fulfill it, and returns the server's response to the client*

## Installation

You know the drill. In your Gemfile

```ruby
gem 'rails-reverse-proxy'
```

Then (you guessed it!)

```
$ bundle
```

## Usage

A use case for this gem is serving WordPress on a path within your Rails application, such as `/blog`. 

To do this, your controller might look like this

```ruby
class WordpressController < ApplicationController
  include ReverseProxy::Controller

  def index
    # Assuming the WordPress server is being hosted on port 8080
    reverse_proxy "http://localhost:8080" do |config|
      # We got a 404!
      config.on_missing do |code, response|
        redirect_to root_url and return
      end

      # There's also other callbacks:
      # - on_set_cookies
      # - on_connect
      # - on_response
      # - on_set_cookies
      # - on_success
      # - on_redirect
      # - on_missing
      # - on_error
      # - on_complete
    end
  end
end
```

Then in your `routes.rb` file, you should have something like

```ruby
match 'blog/*path' => 'wordpress#index', via: [:get, :post, :put, :patch, :delete]
```

You can also pass options into `reverse_proxy`

```ruby
reverse_proxy "http://localhost:8000", path: "custom-path", headers: { 'X-Foo' => "Bar" }
```

If you'd like to bypass SSL verification

```ruby
reverse_proxy "http://localhost:8000", verify_ssl: false
```

If you'd like to customize options passed into the underlying [`Net:HTTP`](https://ruby-doc.org/stdlib-2.4.0/libdoc/net/http/rdoc/Net/HTTP.html#start-method) object

```ruby
reverse_proxy "http://localhost:8000", http: { read_timeout: 20, open_timeout: 100 }
```

Determine what version you're using

```ruby
ReverseProxy.version
```

Feel free to open an issue!

## Contributing

All pull requests will become first class citizens.

## Contributors

Special thanks to our contributors! 

- [miyukki](https://github.com/miyukki)
- [bapirex](https://github.com/bapirex)
- [marcosbeirigo](https://github.com/marcosbeirigo)
- [avinashkoulavkar](https://github.com/avinashkoulavkar)
- [jcs](https://github.com/jcs)

## Copyright

Copyright (c) 2016-2018 James Hu. See [LICENSE](LICENSE) for
further details.
