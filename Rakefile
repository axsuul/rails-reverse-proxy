# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "rails-reverse-proxy"
  gem.homepage = "http://github.com/axsuul/rails-reverse-proxy"
  gem.license = "MIT"
  gem.summary = %Q{Reverse proxy for Ruby on Rails}
  gem.description = %Q{Reverse proxy for Ruby on Rails}
  gem.email = "hello@james.hu"
  gem.authors = ["James Hu"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new