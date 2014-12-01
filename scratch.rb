require_relative "boilerplate"

require "boat"

boat = Boat.from_file("boat.yml")
ap boat
ap Math.cos(boat.foredeck_angle)

ap Constants.all
ap Constants.epoxy_cost
ap Constants.epoxy_cost * "3 gallons"
