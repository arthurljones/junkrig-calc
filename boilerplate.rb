require 'rubygems'
require 'bundler/setup'

Bundler.setup

require "ruby-units"
require "active_support/core_ext"
require "awesome_print"
require "ruby-prof"

ROOT_PATH = File.dirname(File.expand_path(__FILE__))
def add_root_load_path(*args)
  $LOAD_PATH.unshift(File.join(ROOT_PATH, *args))
end

add_root_load_path("src")

def data_file_path(*args)
  File.join(ROOT_PATH, "data", *args)
end

def load_yaml_data_file(*args)
  YAML.load_file(data_file_path(*args)).with_indifferent_access
end


require "monkey_patches"
require "custom_units"
require "constants"
