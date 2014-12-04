require_relative '../spec_helper'
require 'boat'

RSpec.describe Boat do
  def default_boat(overrides = {})
    defaults = {
      displacement: "10000 lbs",
      ballast: "5000 lbs",
      draft_of_canoe_body: "24 in",
      maximum_beam: "11 ft",
      minimum_freeboard: "36 in",
      bow_height_above_water: "60 in",
      length_overall: "35 ft",
      length_at_waterline: "28 ft",
      foredeck_angle: "3 degrees",
    }
    Boat.new(defaults.deep_merge(overrides))
  end

  #TODO: .from_file

  context "with a 35ft, 5ton sailboat" do
    subject! { default_boat }

    it "test" do
      puts subject.capsize_screening_value
    end

    its(:saltwater_displaced) { is_expected.to be_within("0.01 m^3").of "4.43 m^3" }
    its(:ballast_ratio) { is_expected.to be_within(delta).of 0.5 }
    its(:capsize_screening_value) { is_expected.to be_within(0.01).of 2.04 }
    its(:stability_range) { is_expected.to be_within("0.01 deg").of "142.11 deg" }
    its(:displacement_to_length) { is_expected.to be_within(0.01).of 203.37 }
    its(:max_buoyancy_lever) { is_expected.to be_within(delta "in").of "2.75 ft" }
    its(:estimated_max_righting_moment) { is_expected.to be_within(delta "in*lbs").of "3.3e5 in*lbs" }
    its(:water_pressure_at_keel) { is_expected.to be_within("0.01 psi").of "0.89 psi" }

    context "with a specified max_buoyancy_lever" do
      subject! { default_boat(:max_buoyancy_lever => "18 in") }
      its(:max_buoyancy_lever) { is_expected.to eq "18 in" }
      its(:estimated_max_righting_moment) { is_expected.to be_within(delta "in*lbs").of "1.8e5 in*lbs" }
    end
  end
end
