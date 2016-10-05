require 'reverse_proxy/client'
require 'reverse_proxy/controller'

module ReverseProxy
  def version
    File.open(File.expand_path("../../VERSION", __FILE__)).read.strip
  end

  extend self
end