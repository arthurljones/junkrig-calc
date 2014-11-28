require_relative '../../spec_helper'
require_relative '../../../src/cross_sections/tube'

RSpec.describe CrossSections::Tube do
  def default_options
    {
      :outer_diameter => "1.0 in",
      :wall_thickness => "0.125 in"
    }
  end

  def default_tube
    CrossSections::Tube.new(default_options)
  end

  describe "#initialize" do
    it "constructs an object with the passed parameters" do
      tube = default_tube

      expect(tube.outer_diameter).to eq Unit(default_options[:outer_diameter])
      expect(tube.wall_thickness).to eq Unit(default_options[:wall_thickness])
    end

    it "converts compatible units" do
      options = default_options
      options[:outer_diameter] = "25.4 mm"
      tube = CrossSections::Tube.new(options)
      expect(tube.outer_diameter).to eq "1 in"
    end

    it "disallows mismatched units" do
      options = default_options
      options[:outer_diameter] = "10 seconds"
      expect{CrossSections::Tube.new(options)}.to raise_error
    end

    it "disallows invalid values" do
      pending "implementation of this validation"
      options = default_options
      options[:outer_diameter] = "-5 in"
      expect{CrossSections::Tube.new(options)}.to raise_error
    end

  end

  describe "#inner_diameter" do
    it "returns the inner diameter" do
      expect(default_tube.inner_diameter).to eq Unit("0.75 in")
    end
  end

  describe "#outer_radius" do
    it "returns the outer radius" do
      expect(default_tube.outer_radius).to eq Unit("0.5 in")
    end
  end

  describe "#inner_radius" do
    it "returns the inner radius" do
      expect(default_tube.inner_radius).to eq Unit("0.375 in")
    end
  end


end
