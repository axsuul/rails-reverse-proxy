require 'rack'
require 'rack-proxy'

module ReverseProxy
  class Client
    @@callback_methods = [
      :on_response,
      :on_set_cookies,
      :on_success,
      :on_redirect,
      :on_missing,
      :on_error,
      :on_complete
    ]

    # Define callback setters
    @@callback_methods.each do |method|
      define_method(method) do |&block|
        self.callbacks[method] = block
      end
    end

    attr_accessor :url, :callbacks

    def initialize(url)
      self.url = url
      self.callbacks = {}

      # Initialize default callbacks with empty Proc
      @@callback_methods.each do |method|
        self.callbacks[method] = Proc.new {}
      end

      yield(self) if block_given?
    end

    def request(env, options = {}, &block)
      options.reverse_merge!(
        headers: {},
        path: nil,
        username: nil,
        password: nil
      )

      source_request = Rack::Request.new(env)

      # We can pass in a custom path
      uri = URI.parse("#{url}#{options[:path] || env['ORIGINAL_FULLPATH']}")

      # Initialize request
      target_request = Net::HTTP.const_get(source_request.request_method.capitalize).new(uri.request_uri)

      # Setup headers
      target_request_headers = extract_http_request_headers(source_request.env).merge(options[:headers])

      target_request.initialize_http_header(target_request_headers)

      # Basic auth
      target_request.basic_auth(options[:username], options[:password]) if options[:username] and options[:password]

      # Setup body
      if target_request.request_body_permitted? \
         && source_request.body
        source_request.body.rewind
        target_request.body_stream = source_request.body
      end

      target_request.content_length = source_request.content_length || 0
      target_request.content_type   = source_request.content_type if source_request.content_type

      # Hold the response here
      target_response = nil

      # Don't encode response/support compression which was
      # causing content length not match the actual content
      # length of the response which ended up causing issues
      # within Varnish (503)
      target_request['Accept-Encoding'] = nil

      # Make the request
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == "https")) do |http|
        target_response = http.request(target_request)
      end

      status_code = target_response.code.to_i
      payload = [status_code, target_response]

      callbacks[:on_response].call(payload)

      if set_cookie_headers = target_response.to_hash['set-cookie']
        set_cookies_hash = {}

        set_cookie_headers.each do |set_cookie_header|
          set_cookie_hash = parse_cookie(set_cookie_header)
          name = set_cookie_hash[:name]
          set_cookies_hash[name] = set_cookie_hash
        end

        callbacks[:on_set_cookies].call(payload | [set_cookies_hash])
      end

      case status_code
      when 200..299
        callbacks[:on_success].call(payload)
      when 300..399
        if redirect_url = target_response['Location']
          callbacks[:on_redirect].call(payload | [redirect_url])
        end
      when 400..499
        callbacks[:on_missing].call(payload)
      when 500..599
        callbacks[:on_error].call(payload)
      end

      callbacks[:on_complete].call(payload)

      payload
    end

  private

    def extract_http_request_headers(env)
      headers = env.reject do |k, v|
        !(/^HTTP_[A-Z_]+$/ === k) || v.nil?
      end.map do |k, v|
        [reconstruct_header_name(k), v]
      end.inject(Rack::Utils::HeaderHash.new) do |hash, k_v|
        k, v = k_v
        hash[k] = v
        hash
      end

      headers
    end

    def reconstruct_header_name(name)
      name.sub(/^HTTP_/, "").gsub("_", "-")
    end

    COOKIE_PARAM_PATTERN = /\A([^(),\/<>@;:\\\"\[\]?={}\s]+)(?:=([^;]*))?\Z/
    COOKIE_SPLIT_PATTERN = /;\s*/

    def parse_cookie(cookie_str)
      params = cookie_str.split(COOKIE_SPLIT_PATTERN)
      info = params.shift.match(COOKIE_PARAM_PATTERN)
      return {} unless info

      cookie = {
        name: info[1],
        value: CGI.unescape(info[2]),
      }

      params.each do |param|
        result = param.match(COOKIE_PARAM_PATTERN)
        next unless result

        key = result[1].downcase.to_sym
        value = result[2]
        case key
        when :expires
          begin
            cookie[:expires] = Time.parse(value)
          rescue ArgumentError
          end
        when *[:httponly, :secure]
          cookie[key] = true
        else
          cookie[key] = value
        end
      end

      cookie
    end
  end
end
