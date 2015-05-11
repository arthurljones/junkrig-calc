require_relative "../boilerplate"
require "sail/sail"

sail = Sail::Sail.new(load_yaml_data_file("sail.yml"))
sail.draw_to_file(ARGV[0] || "sail.svg")
