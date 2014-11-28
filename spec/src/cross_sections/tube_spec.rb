require_relative '../../spec_helper'
require_relative '../../../src/cross_sections/tube'

RSpec.describe CrossSections::Tube do
  def default_options
    {
      :outer_diameter => "1.0 in",
      :wall_thickness => "0.125 in"
    }
  end

  describe "#initialize" do
    it "constructs a valid object" do
      tube = CrossSections::Tube.new(default_options)

      expect(tube.outer_diameter).to eq Unit(default_options[:outer_diameter])
      expect(tube.wall_thickness).to eq Unit(default_options[:wall_thickness])
    end
  end
end
