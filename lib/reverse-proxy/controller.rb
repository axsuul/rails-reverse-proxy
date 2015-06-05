module ReverseProxy
  module Controller
    def reverse_proxy(proxy_url, options = {})
      proxy_uri = Addressable::URI.parse(proxy_url)

      client = ReverseProxy::Client.new(proxy_url) do |config|
        config.on_response do |code, response|
          blacklist = [
            'Connection',           # Always close connection
            'Transfer-Encoding',    # Let Rails calculate this
            'Content-Length'        # Let Rails calculate this
          ]

          response.each_capitalized do |key, value|
            next if blacklist.include?(key)

            headers[key] = value
          end
        end

        config.on_set_cookies do |code, response, set_cookies|
          set_cookies.each do |key, attributes|
            cookies[key] = attributes
          end
        end

        config.on_redirect do |code, response, redirect_url|
          request_uri = Addressable::URI.parse(request.url)
          redirect_uri = Addressable::URI.parse(redirect_url)

          # Make redirect uri absolute if it's relative by
          # joining it with the request url
          redirect_uri = request_uri.join(redirect_url) if redirect_uri.host.nil?

          unless redirect_uri.port.nil?
            # Make sure it's consistent with our request port
            redirect_uri.port = request.port if redirect_uri.port == proxy_uri.port
          end

          redirect_to redirect_uri.to_s, status: code and return
        end

        config.on_complete do |code, response|
          content_type = response['Content-Type']
          body = response.body.to_s

          if content_type and content_type.match /image/
            send_data body, content_type: content_type, disposition: "inline", status: code
          else
            render text: body, content_type: content_type, status: code
          end
        end

        yield(config) if block_given?
      end

      client.request(env, options)
    end
  end
end