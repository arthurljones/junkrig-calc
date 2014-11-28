require 'rubygems'
require 'bundler/setup'

Bundler.require
Dir.glob("../src/**/*.rb").each { |file| require_relative file }
