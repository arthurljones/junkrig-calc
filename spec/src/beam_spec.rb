require_relative '../spec_helper'
require_relative '../../src/beam'
require_relative '../../src/material'

RSpec.describe Beam do
  def default_cross_section
    CrossSections::Tube.new(
      :outer_diameter => "1.0 in",
      :wall_thickness => "0.125 in"
    )
  end

  def default_options(cross_section = default_cross_section)
    {
      :material => Material.get("6061-T6 Aluminum"),
      :cross_section => cross_section,
      :length => "100 in"
    }
  end

  def force_delta
    "0.001 lbf"
  end

  def default_beam
    Beam.new(default_options)
  end

  describe "#volume" do
    it "returns the volume of the beam" do
      expect(default_beam.volume).to be_within(delta("in^3")).of("34.3611696486 in^3")
    end
  end

  describe "#weight" do
    it "returns the weight of the beam" do
      expect(default_beam.weight).to be_within("0.001 lbs").of("3.350 lbs")
    end
  end

  describe "#cantilever_end_load_limit" do
    it "returns the maximum point load that can be applied to the end of the cantilever" do
      expect(default_beam.cantilever_end_load_limit).to be_within(force_delta).of("26.845 lbf")
    end
  end

  describe "#cantilever_uniform_load_limit" do
    it "returns the maximum load that can be applied uniformly along the length of the cantilever" do
      expect(default_beam.cantilever_uniform_load_limit).to be_within(force_delta).of("53.689 lbf")
    end
  end

  describe "#simply_supported_center_load_limit" do
    it "returns the maximum point load that can be applied to the center of the simply supported beam" do
      expect(default_beam.simply_supported_center_load_limit).to be_within(force_delta).of("107.379 lbf")
    end
  end

  describe "#simply_supported_uniform_load_limit" do
    it "returns the maximum load that can be applied uniformly along the length of the simply supported beam" do
      expect(default_beam.simply_supported_uniform_load_limit).to be_within(force_delta).of("214.757 lbf")
    end
  end
end
