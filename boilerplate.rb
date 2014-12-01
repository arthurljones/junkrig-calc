require 'rubygems'
require 'bundler/setup'

Bundler.setup

require "ruby-units"
require "active_support/core_ext"
require "awesome_print"

def add_root_load_path(*args)
  $LOAD_PATH.unshift(File.join(File.dirname(File.expand_path(__FILE__)), *args))
end

add_root_load_path("src")
