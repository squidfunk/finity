# -*- encoding: utf-8 -*-
require File.expand_path("../lib/finity/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'finity'
  s.version     = Finity::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Martin Donath']
  s.email       = 'md@struct.cc'
  s.homepage    = 'http://github.com/squidfunk/finity'
  s.summary     = 'Super slim Ruby state machine'
  s.description = 'Extremly lightweight state machine implementation in Ruby'

  s.required_rubygems_version = '>= 1.3.6'
  #s.rubyforge_project         = 'finity'

  s.add_development_dependency 'bundler', '~> 1'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
