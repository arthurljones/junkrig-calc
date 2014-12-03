require_relative '../../spec_helper'
require 'engineering/beam'

RSpec.describe Engineering::Beam do
  def default_beam(overrides = {})
    defaults = {
      :material => "6061-T6 Aluminum",
      :length => "100 in",
      :cross_section => {
        :type => :tube,
        :outer_diameter => "1.0 in",
        :wall_thickness => "0.125 in"
      }
    }
    Engineering::Beam.new(defaults.deep_merge(overrides))
  end

  let!(:force_delta) { "0.001 lbf" }

  context "an aluminum tube 100 inches long by 1 inch in diameter with 1/8 inch wall" do
    subject { default_beam }

    its(:volume) { is_expected.to be_within("0.001 in^3").of("34.361 in^3") }
    its(:weight) { is_expected.to be_within("0.001 lbs").of("3.350 lbs") }

    context "with fixed-free (cantilever) attachment" do
      subject { default_beam(attachment_type: [:fixed, :free]) }

      its(:min_point_load_limit) { is_expected.to be_within(force_delta).of("26.845 lbf") }
      its(:min_uniform_load_limit) { is_expected.to be_within(force_delta).of("53.689 lbf") }
      its(:buckling_load_limit) { is_expected.to be_within(force_delta).of("74.690 lbf") }
    end

    context "with hinged-hinged (simply supported) attachment" do
      subject { default_beam(attachment_type: [:hinged, :hinged]) }

      its(:min_point_load_limit) { is_expected.to be_within(force_delta).of("107.379 lbf") }
      its(:min_uniform_load_limit) { is_expected.to be_within(force_delta).of("214.757 lbf") }
      its(:buckling_load_limit) { is_expected.to be_within(force_delta).of("323.390 lbf") }
    end
  end
end
