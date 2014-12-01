require_relative '../spec_helper'
require 'boat'

RSpec.describe Boat do
  def default_options(overrides = {})
    {
      displacement: "10000 lbs",
      ballast: "5000 lbs",
      draft_of_canoe_body: "24 in",
      maximum_beam: "11 ft",
      minimum_freeboard: "36 in",
      bow_height_above_water: "60 in",
      length_overall: "35 ft",
      length_at_waterline: "28 ft",
      foredeck_angle: "3 degrees",
    }.merge(overrides)
  end

  def default_boat(overrides = {})
    Boat.new(default_options(overrides))
  end

  describe ".from_file" do
    #TODO
  end

  describe "#saltwater_displaced" do
    it "returns the volume of seawater displaced by the boat" do
      expect(default_boat.saltwater_displaced).to be_within("0.01 m^3").of "4.43 m^3"
    end
  end

  describe "#ballast_ratio" do
    it "returns the ratio of ballast to total displacement" do
      expect(default_boat.ballast_ratio).to be_within(delta).of 0.5
    end
  end

  describe "#screening_stability_value" do
    it "returns a composite value that represents the stability of the boat" do
      expect(default_boat.screening_stability_value).to be_within(0.01).of 22.46
    end
  end

  describe "#stability_range" do
    it "returns the angle at which the boat loses upright stability" do
      expect(default_boat.stability_range).to be_within("0.01 deg").of "142.11 deg"
    end
  end

  describe "#displacement_to_length" do
    it "returns a composite ratio relating the displacement to the waterline length" do
      expect(default_boat.displacement_to_length).to be_within(0.01).of 203.37
    end
  end

  describe "#buoyancy_lever" do
    it "returns the buoyancy lever specified on construction, if it exists" do
      expect(default_boat(:buoyancy_lever => "18 in").buoyancy_lever).to eq "18 in"
    end

    it "estimates the buoyancy lever if none was provided" do
      expect(default_boat.buoyancy_lever).to be_within(delta "in").of "2.75 ft"
    end
  end

  describe "#estimated_max_righting_moment" do
    it "returns the righting moment if the boat was knocked down, but the center of buoyancy stayed the same" do
      expect(default_boat.estimated_max_righting_moment).to be_within(delta "in*lbs").of "3.3e5 in*lbs"
    end
  end

  describe "#water_pressure_at_keel" do
    it "returns the saltwater pressure outside the hull at the top of the keel" do
      expect(default_boat.water_pressure_at_keel).to be_within("0.01 psi").of "0.89 psi"
    end
  end

end
