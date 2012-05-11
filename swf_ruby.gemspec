# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'swf_ruby/version'

Gem::Specification.new do |s|
  s.name        = "swf_ruby"
  s.version     = SwfRuby::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["tmtysk"]
  s.email       = []
  s.homepage    = "http://github.com/tmtysk/swf_ruby"
  s.summary     = "Utilities to dump or manipulate Swf binary file."
  s.description = "SwfRuby is utilities to dump or manipulate Swf binary file."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "swf_ruby"

  s.add_dependency "bundler", ">= 1.0.0.rc.5"
  s.add_dependency "rmagick", ">= 2.13.0"

  s.bindir             = 'bin'
  s.executables        = ['swf_dump', 'swf_jpeg_replace', 'swf_lossless_replace', 'swf_as_var_replace', 'swf_sprite_replace']

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'
end
