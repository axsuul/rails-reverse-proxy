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

Sorry if these instructions are sparse. Feel free to reach out or read the source!

## Contributing

All pull requests will become first class citizens.

## Thanks

Special thanks to our contributors!

- [miyukki](https://github.com/miyukki)

## Copyright

Copyright (c) 2016 James Hu. See LICENSE.txt for
further details.

