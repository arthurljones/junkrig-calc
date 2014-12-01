require_relative '../../../spec_helper'
require 'engineering/cross_sections/birdsmouth'

RSpec.describe Engineering::CrossSections::Birdsmouth do
  def default_options
    {
      :stave_thickness => "2 in",
      :stave_width => "4 in",
      :defect_to_total_area_ratio => 0.02
    }
  end

  def default_section
    Engineering::CrossSections::Birdsmouth.new(default_options)
  end

  describe "#initialize" do
    it "constructs an object with the passed parameters" do
    end

    it "converts compatible units" do
    end

    it "disallows mismatched units" do
    end

    it "disallows invalid values" do
    end

  end

  describe "#outer_radius"

  describe "#outer_diameter" do
    it "returns the outer diameter" do
      expect(default_section.outer_diameter).to be_within(delta "in").of "10.2426406871 in"
    end
  end

  describe "#inner_diameter" do
    it "returns the inner diameter" do
      expect(default_section.inner_diameter).to be_within(delta "in").of "6.756985589 in"
    end
  end

  describe "#wall_thickness" do
    it "returns the minimum thickness of the birdsmouth tube wall" do
      expect(default_section.wall_thickness).to be_within(delta "in").of "1.7428275491 in"
    end
  end

  #Common cross section methods

  describe "#extreme_fiber_radius" do
    it "returns the distance from the neutral axis to the furthest fiber of the cross section, which should equal the outer radius" do
      section = default_section
      expect(section.extreme_fiber_radius).to eq(section.outer_diameter / 2)
    end
  end

  describe "#area" do
    it "returns the area of the cross section" do
      expect(default_section.area).to be_within(delta "in^2").of "50.1131760194 in^2"
    end
  end

  describe "#second_moment_of_area" do
    it "returns the second moment of area" do
      expect(default_section.second_moment_of_area).to be_within(delta "in^4").of "421.5883461605 in^4"
    end
  end

  describe "#elastic_section_modulus" do
    it "returns the elastic section modulus (second moment of area / extreme fiber radius)" do
      expect(default_section.elastic_section_modulus).to be_within(delta "in^3").of "82.3202451475 in^3"
    end
  end

end
