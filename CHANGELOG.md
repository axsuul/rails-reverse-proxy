## 0.13.0

BUG FIXES:

* **Rack 3 compatibility:** Use `Rack::Headers` if defined (i.e. if using Rack >= 3.0.0), otherwise use `Rack::Utils::HeaderHash` [[#76](https://github.com/axsuul/rails-reverse-proxy/pull/76), [davidrunger](https://github.com/davidrunger)]

## 0.11.0

BUG FIXES:

* Update nokogiri gem in development to work with arm64 systems

BREAKING CHANGES:

* Add option to pass through compression, with new default as disabled [[#27](https://github.com/axsuul/rails-reverse-proxy/pull/27), [kylewlacy](https://github.com/kylewlacy)]
