# rails-reverse-proxy

Gives you the ability to reverse proxy within Rails.

## Installation

You know the drill. In your Gemfile, have the line

```ruby
gem 'rails-reverse-proxy'
```

Then (you guessed it!)

```
$ bundle
```

## Usage

An example usage of this gem is hosting a WordPress site on a path within your Rails application, such as `/blog`. To do this, you'll need something like

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

If you'd like to customize the options passed into the [HTTP session](https://ruby-doc.org/stdlib-2.4.0/libdoc/net/http/rdoc/Net/HTTP.html#start-method)

```ruby
reverse_proxy "http://localhost:8000", http: { read_timeout: 20, open_timeout: 100 }
```

Use this method to determine what version you're running

```ruby
ReverseProxy.version
```

Feel free to open an issue!

## Contributing

All pull requests will become first class citizens.

## Thanks

Special thanks to our contributors!

- [miyukki](https://github.com/miyukki)
- [bapirex](https://github.com/bapirex)
- [marcosbeirigo](https://github.com/marcosbeirigo)
- [avinashkoulavkar](https://github.com/avinashkoulavkar)
- [jcs](https://github.com/jcs)

## Copyright

Copyright (c) 2016-2017 James Hu. See [LICENSE](LICENSE) for
further details.
