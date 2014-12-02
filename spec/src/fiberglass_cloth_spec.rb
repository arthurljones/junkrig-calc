require_relative '../spec_helper'
require 'fiberglass_cloth'

RSpec.describe FiberglassCloth do
  def default_options(overrides = {})
    {
      weight_per_area: "10 oz/yd^2",
      cost_per_fifty_inch_yard: "5.00 USD",
    }.merge(overrides)
  end

  def default_boat(overrides = {})
    FiberglassCloth.new(default_options(overrides))
  end

  describe ".get_by_oz" do
    #TODO
  end

  describe "#cost_per_area" do
    it "returns the cost of the fiberglass per unit area" do
      expect(default_boat.cost_per_area).to be_within("0.001 USD/in^2").of "0.0028 USD/in^2"
    end
  end

  describe "#cost_per_volume" do
    it "returns the cost of the fiberglass per unit volume" do
      expect(default_boat.cost_per_volume).to be_within("0.001 USD/in^3").of "0.167 USD/in^3"
    end
  end

  describe "#cost_per_weight" do
    it "returns the cost of the fiberglass per unit weight" do
      expect(default_boat.cost_per_weight).to be_within("0.001 USD/lb").of "5.760 USD/lb"
    end
  end

  describe "#finished_cost_per_weight" do
    it "returns the cost of the finished laminate per unit weight" do
      expect(default_boat.finished_cost_per_weight).to be_within("0.001 USD/lb").of "6.005 USD/lb"
    end
  end

  describe "#finished_cost_per_volume" do
    it "returns the cost of the finished laminate per unit volume" do
      expect(default_boat.finished_cost_per_volume).to be_within("0.001 USD/in^3").of "0.330 USD/in^3"
    end
  end

  describe "#ply_thickness" do
    it "returns the thickness of each ply of fiberglass cloth" do
      expect(default_boat.ply_thickness).to be_within("0.001 in").of "0.017 in"
    end
  end
end
