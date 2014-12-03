require_relative "../boilerplate"

add_root_load_path("spec/src")

require_relative "support/helpers"

require 'rspec/its'

RSpec.configure do |config|
  # RSpec automatically cleans stuff out of backtraces;
  # sometimes this is annoying when trying to debug something e.g. a gem

  config.full_backtrace=false
  config.include RSpecHelpers
end
