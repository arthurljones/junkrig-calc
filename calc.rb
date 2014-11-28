require 'rubygems'
require 'bundler/setup'

Bundler.require
Dir.glob("src/**/*.rb").each { |file| require_relative file }

material_data = YAML.load_file("materials.yml")
materials = material_data.collect{ |data| Material.new(data.with_indifferent_access) }
ap materials
