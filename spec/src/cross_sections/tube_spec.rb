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
      options[:outer_diameter] = "50.8 mm"
      tube = CrossSections::Tube.new(options)
      expect(tube.outer_diameter).to eq "2 in"
    end

    it "disallows mismatched units" do
      options = default_options
      options[:outer_diameter] = "10 seconds"
      expect{CrossSections::Tube.new(options)}.to raise_error
    end

    it "disallows invalid values" do
      expect{CrossSections::Tube.new(default_options.merge(:outer_diameter => "0 in"))}.to raise_error
      expect{CrossSections::Tube.new(default_options.merge(:outer_diameter => "-5 in"))}.to raise_error
      expect{CrossSections::Tube.new(default_options.merge(:wall_thickness => "0 in"))}.to raise_error
      expect{CrossSections::Tube.new(default_options.merge(:wall_thickness => "-5 in"))}.to raise_error
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

  describe "#extreme_fiber_radius" do
    it "returns the second moment of area" do
      expect(default_tube.extreme_fiber_radius).to eq Unit("0.5 in")
    end
  end

  describe "#area" do
    it "returns the area" do
      expect(default_tube.area).to be_within(delta "in^2").of "0.34361170 in^2"
    end
  end

  describe "#second_moment_of_area" do
    it "returns the second moment of area" do
      expect(default_tube.second_moment_of_area).to be_within(delta "in^4").of "0.03355583 in^4"
    end
  end


  describe "#elastic_section_modulus" do
    it "returns the second moment of area" do
      expect(default_tube.elastic_section_modulus).to be_within(delta "in^3").of "0.06711166 in^3"
    end
  end

end
