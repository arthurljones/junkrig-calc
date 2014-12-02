require_relative "boilerplate"

require "sail/sail"

root = File.expand_path(File.dirname(__FILE__))
sail_data = YAML.load_file(File.join(root, "sail.yml")).with_indifferent_access
sail = Sail::Sail.new(sail_data)
sail.draw_to_file(ARGV[0] || "sail.svg")
