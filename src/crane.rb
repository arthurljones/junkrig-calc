require "options_initializer"
require "math/vector2"

class Crane
  include OptionsInitializer

  attr_reader *%i(

  )

  options_initialize(
    :dummy => {:default => 0}
  ) do |options|
    zero_dist = Unit.new("0 in")

    #TODO: Pull these from the initializer
    @running_line_purchase = 6
    @mast_pivot_to_pulley = Vector2.new(Unit.new("110 in"), Unit.new("-8 in"))
    @mast_pivot_to_crane_pivot = Vector2.new(Unit.new("-4 ft"), Unit.new("0 in"))
    @crane_base_width = Unit.new("70 in")
    @crane_crossmember_height = Unit.new("86 in")
    @initial_crane_angle = Unit.new("80 deg")
    @guy_anchor_above_pivot = Unit.new("31.7 ft")
    @mast_center_to_pivot_x = Unit.new("-0.75 ft")
    @mast_foot_to_pivot_y = Unit.new("3.3 ft")
    @mast_center_of_mass_above_foot = Unit.new("183.34 in")
    @mast_weight = Unit.new("249.3 lbs")
    @minimum_angle = Unit.new("16 deg")

    @crane_height = (@mast_pivot_to_crane_pivot - @mast_pivot_to_pulley).magnitude

    #Chain Basket - line around curved segment at foot of mast lifts anchor chain (300 ft of 5/16") at bottom of mast travel
    #TODO: Smoother curve instead of sharp cutout (which would physically look like a spiral section)
    max_chain_basket_lift = Unit.new("3 ft")
    chain_weight = Unit.new("300 lbs")
    @lift_assist_torque = Unit.new("0 ft*lbs") #@mast_foot_to_pivot_y * chain_weight
    @lift_assist_torque_cutout_angle = Unit.new(@mast_foot_to_pivot_y / max_chain_basket_lift, "rad")

    #Mast Pivot
    @mast_foot_center_to_pivot = Vector2.new(@mast_center_to_pivot_x, @mast_foot_to_pivot_y)
    @pivot_height_above_deck = Unit.new("0.0 ft")

    #Mast center of mass
    @pivot_to_mast_cm_initial = (Vector2.new(zero_dist, @mast_center_of_mass_above_foot) - @mast_foot_center_to_pivot).rotated_by(Unit.new("90 deg"))

    #NOTE: This coordinate system has the mast pivot at (0, 0)

    #Crane
    @crane_tip_initial = @mast_pivot_to_crane_pivot + Vector2.new(@crane_height, zero_dist).rotated_by(@initial_crane_angle)

    #Guy
    @guy_anchor_zero = Vector2.new(@guy_anchor_above_pivot, zero_dist)
    @guy_anchor_initial = -@guy_anchor_zero #TODO: Simplify this so only the zero or inital is used (at least one is misnamed)
    @guy_length = (@guy_anchor_initial - @crane_tip_initial).magnitude #D7

  end

  def calculate(angle_above_horizontal)
    angle_above_horizontal = [@minimum_angle, angle_above_horizontal].max

    #Mirror the calculation across the y axis to align boat's bow to the right
    angle = Unit.new(Math::PI, "radians") - angle_above_horizontal

    static_torque = (-@pivot_to_mast_cm_initial.rotated_by(angle) * @mast_weight).x
    static_torque += @lift_assist_torque if angle_above_horizontal <= @lift_assist_torque_cutout_angle

    guy_anchor = @guy_anchor_zero.rotated_by(angle)
    guy_anchor_to_crane_pivot = @mast_pivot_to_crane_pivot - guy_anchor
    guy_anchor_to_crane_pivot_length = guy_anchor_to_crane_pivot.magnitude
    γ = Math::acos((guy_anchor_to_crane_pivot_length ** 2 + @crane_height ** 2 - @guy_length ** 2) / (-2 * @crane_height * guy_anchor_to_crane_pivot_length))

    crane_angle = guy_anchor_to_crane_pivot.angle + Unit.new(γ, "rad")
    crane_vector = Vector2.new(@crane_height, "0 in").rotated_by(crane_angle)

    crane_tip_to_guy_anchor_vector = guy_anchor_to_crane_pivot + crane_vector
    guy_angle = Unit.new((crane_tip_to_guy_anchor_vector.to("ft").unitless.to_complex / Complex(@guy_length.to("ft").scalar, 0)).angle, "rad")
    guy_angle_to_crane = crane_angle - guy_angle
    guy_torque_lever = guy_anchor_to_crane_pivot_length * Math::sin(guy_anchor_to_crane_pivot.angle - guy_angle)

    crane_tip = @mast_pivot_to_crane_pivot + crane_vector

    line_vector = crane_tip - @mast_pivot_to_pulley
    crane_tip_above_pulley = line_vector.dot(Vector2.new("0 in", "1 in")) > 0
    line_length = line_vector.magnitude
    line_angle = line_vector.angle
    line_angle_to_crane = line_angle - crane_angle #TODO: This seems backward or at least misnamed
    line_angle_to_guy = line_angle_to_crane + guy_angle_to_crane

    line_force = (static_torque * Math::sin(guy_angle_to_crane)) / (Math::sin(line_angle_to_crane) * guy_torque_lever)

    crane_force = line_force * Math::sin(line_angle_to_guy) / Math::sin(guy_angle_to_crane)

    guy_force = static_torque / guy_torque_lever

    guy_anchor_position = guy_anchor
    crane_pivot_position = @mast_pivot_to_crane_pivot
    pulley_position = @mast_pivot_to_pulley
    mast_pivot_position = Vector2.new("0 in", "0 in")

    {
      mast_angle: angle_above_horizontal,
      line_length: line_length * @running_line_purchase,
      crane_tip_above_pulley: crane_tip_above_pulley,
      line_force: line_force,
      crane_force: crane_force,
      guy_force: guy_force,
      guy_anchor: guy_anchor_position,
      crane_tip: crane_tip,
      crane_pivot: crane_pivot_position,
      pulley: pulley_position,
      mast_pivot: mast_pivot_position,
    }
  end

end
