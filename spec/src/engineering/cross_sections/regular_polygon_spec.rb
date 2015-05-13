require_relative '../../../spec_helper'
require 'engineering/cross_sections/regular_polygon'

RSpec.describe Engineering::CrossSections::RegularPolygon do
  def default_options
    {
      :circumradius => "5 in",
      :sides => 8,
    }
  end

  def default_section
    Engineering::CrossSections::RegularPolygon.new(default_options)
  end

  #Common cross section methods

  describe "#extreme_fiber_radius" do
    it "returns the distance from the neutral axis to the furthest fiber of the cross section, which should equal the outer radius" do
      section = default_section
      expect(section.extreme_fiber_radius).to eq(section.circumradius)
    end
  end

  describe "#area" do
    it "returns the area of the cross section" do
      expect(default_section.area).to be_within(delta "in^2").of "70.71067812 in^2"
    end
  end

  describe "#second_moment_of_area" do
    it "returns the second moment of area" do
      expect(default_section.second_moment_of_area).to be_within(delta "in^4").of "463.51536128 in^4"
    end
  end

  describe "#elastic_section_modulus" do
    it "returns the elastic section modulus (second moment of area / extreme fiber radius)" do
      expect(default_section.elastic_section_modulus).to be_within(delta "in^3").of "92.70307226 in^3"
    end
  end

  describe "#circumference" do
    it "returns the outer circumference" do
      expect(default_section.circumference).to be_within(delta "in").of "30.61467459 in"
    end
  end

  describe "#side_length" do
    it "returns the area of the cross section" do
      expect(default_section.side_length).to be_within(delta "in").of "3.82683432 in"
    end
  end

  describe "#circumradius" do
      it "returns the area of the cross section" do
        section = Engineering::CrossSections::RegularPolygon.new(:sides => 8, :side_length => "3.82683432 in")
        expect(section.circumradius).to be_within(delta "in").of "5 in"
      end
    end
end
