require_relative '../../../spec_helper'
require 'engineering/cross_sections/rounded_box'

RSpec.describe Engineering::CrossSections::RoundedBox do
  def default_options
    {
      :height => "10 in",
      :width => "10 in",
      :wall_thickness => "1.5 in",
      :corner_radius => "3 in",
      :defect_width => "0.75 in",
      :gusset_size => "1.5 in"
    }
  end

  def default_section
    Engineering::CrossSections::RoundedBox.new(default_options)
  end

  #Common cross section methods

  describe "#extreme_fiber_radius" do
    it "returns the distance from the neutral axis to the furthest fiber of the cross section, which should equal the outer radius" do
      section = default_section
      expect(section.extreme_fiber_radius).to eq(section.height / 2)
    end
  end

  describe "#area" do
    it "returns the area of the cross section" do
      expect(default_section.area).to be_within(delta "in^2").of "52.274333882 in^2"
    end
  end

  describe "#second_moment_of_area" do
    it "returns the second moment of area" do
      expect(default_section.second_moment_of_area).to be_within(delta "in^4").of "508.605211764 in^4"
    end
  end

  describe "#elastic_section_modulus" do
    it "returns the elastic section modulus (second moment of area / extreme fiber radius)" do
      expect(default_section.elastic_section_modulus).to be_within(delta "in^3").of "101.721042353 in^3"
    end
  end

  describe "#minimum_thickness" do
    it "returns the minimum wall thickness" do
      expect(default_section.minimum_thickness).to be_within(delta "in").of "1.5 in"
    end
  end

  describe "#circumference" do
    it "returns the outer circumference" do
      expect(default_section.circumference).to be_within(delta "in").of "34.8495559215 in"
    end
  end

end
