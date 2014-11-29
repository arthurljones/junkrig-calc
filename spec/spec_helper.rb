require 'rubygems'
require 'bundler/setup'

Bundler.require
Dir.glob("../src/**/*.rb").each { |file| require_relative file }

require_relative "support/helpers"

RSpec.configure do |config|
  # RSpec automatically cleans stuff out of backtraces;
  # sometimes this is annoying when trying to debug something e.g. a gem

  config.full_backtrace=false
  config.include RSpecHelpers
end
