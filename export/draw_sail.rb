require_relative "../boilerplate"
require "sail/sail"

data = load_yaml_data_file("boat.yml")
sail = Sail::Sail.new(data[:mast][:sail])
sail.draw_to_file(ARGV[0] || "sail.svg")
