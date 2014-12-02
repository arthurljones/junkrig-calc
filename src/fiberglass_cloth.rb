require "options_initializer"
require "engineering/material"
require "yaml"

class FiberglassCloth
  include OptionsInitializer

  @@data = {}

  attr_reader *%i(
    cost_per_area
    cost_per_volume
    cost_per_weight
    finished_cost_per_volume
    finished_cost_per_weight
    ply_thickness
  )

  options_initialize(
    weight_per_area: { units: "oz/yd^2" },
    cost_per_fifty_inch_yard: { units: "USD", write: false },
  ) do |options|
    @cost_per_area = (options[:cost_per_fifty_inch_yard] / (Unit("1 yd") * Unit("50 in"))).to("USD/in^2")
    @ply_thickness = (@weight_per_area / Constants.fiberglass_cloth_density).to("in")
    @cost_per_volume = (@cost_per_area / @ply_thickness).to("USD/in^3")
    @cost_per_weight = (@cost_per_area / @weight_per_area).to("USD/lb")

    epoxy_ratio = Constants.fiberglass_resin_weight_ratio
    fiberglass_ratio = 1 - epoxy_ratio
    fiberglass_density = Engineering::Material.get("Fiberglass").density
    epoxy_cost_per_weight = Constants.epoxy_cost / Constants.epoxy_density
    @finished_cost_per_weight = (@cost_per_weight * fiberglass_ratio + epoxy_cost_per_weight * epoxy_ratio).to("USD/lb")
    @finished_cost_per_volume = (@finished_cost_per_weight * fiberglass_density).to("USD/in^3")
  end

  def get_by_oz
    @@cache
  end

  def data
    if @@data.blank?
      dir = File.expand_path(File.dirname(__FILE__))
      data = YAML.load_file(File.join(dir, "..", "fiberglass.yml")).with_indifferent_access
      @@data = data.inject({}) do |result, (key, val)|
        weight = Unit(key)
        cost = Unit(value)
        result[weight.scalar] = new(weight_per_area: weight, cost_per_fifty_inch_yard: cost)
        result
      end
    end
    @@data
  end
end
