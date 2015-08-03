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
    @pulley_to_mast_pivot_along_deck = Unit.new("128 in")
    @crane_height = Unit.new("14 ft")
    @anchor_moves_with_mast = false
    @crane_base_width = Unit.new("70 in")
    @crane_crossmember_height = Unit.new("86 in")
    @initial_crane_angle = Unit.new("60 deg") #Seems like we should be able to calculate this to produce a given pulley clearance.
    @mast_pivot_height_above_crane_anchor = Unit.new("18 in")
    @guy_anchor_above_pivot = Unit.new("31.7 ft")

    #Mast Pivot
    @below_pivot_weight = Unit.new("29.8647651632 lbs")
    @below_pivot_center_of_mass = Unit.new("1.6666666667 ft")
    @above_pivot_weight = Unit.new("219.391159468 lbs")
    @above_pivot_center_of_mass = Unit.new("12.9012345679 ft")
    @pivot_height_above_deck = Unit.new("0.0 ft")

    #NOTE: This coordinate system has the mast pivot at (0, 0)

    #Pulley
    @foredeck_angle = Unit.new("3 deg")
    along_deck = Vector2.new(@pulley_to_mast_pivot_along_deck, zero_dist)
    pivot_to_deck = Vector2.new(zero_dist, -@pivot_height_above_deck)
    @mast_pivot_to_pulley = along_deck.rotated_by(@foredeck_angle) + pivot_to_deck

    #Crane
    @crane_anchor_zero = Vector2.new(-(@crane_height - @pulley_to_mast_pivot_along_deck), -(@mast_pivot_height_above_crane_anchor))
    @crane_tip_initial = @crane_anchor_zero + Vector2.new(@crane_height, zero_dist).rotated_by(@initial_crane_angle)

    #Guy
    @guy_anchor_zero = Vector2.new(@guy_anchor_above_pivot, zero_dist)
    @guy_anchor_initial = -@guy_anchor_zero #TODO: Simplify this so only the zero or inital is used (at least one is misnamed)
    @guy_length = (@guy_anchor_initial - @crane_tip_initial).magnitude #D7

    calculate(Unit.new("30 deg"))
    #calculate(Unit.new("10 deg"))
    #calculate(Unit.new("20 deg"))
    #calculate(Unit.new("30 deg"))
  end

  def calculate(angle_above_horizontal)
    angle = Unit(Math::PI, "radians") - angle_above_horizontal
    below_pivot_torque = @below_pivot_weight * @below_pivot_center_of_mass * Math::cos(angle)
    above_pivot_torque = @above_pivot_weight * @above_pivot_center_of_mass * Math::cos(angle)
    static_torque = above_pivot_torque - below_pivot_torque #C7

    crane_anchor = @crane_anchor_zero
    crane_anchor = crane_anchor.rotated_by(angle_above_horizontal) if @anchor_moves_with_mast #TODO: Why is it using this angle that's 180º out?
    guy_anchor = @guy_anchor_zero.rotated_by(angle)
    guy_anchor_to_crane_anchor = crane_anchor - guy_anchor #C11
    guy_anchor_to_crane_anchor_length = guy_anchor_to_crane_anchor.magnitude
    γ = Math::acos((guy_anchor_to_crane_anchor_length ** 2 + @crane_height ** 2 - @guy_length ** 2) / (-2 * @crane_height * guy_anchor_to_crane_anchor_length))

    crane_angle = guy_anchor_to_crane_anchor.angle + Unit.new(γ, "rad")
    crane_vector = Vector2.new(@crane_height, "0 in").rotated_by(crane_angle) #C14

    crane_tip_to_guy_anchor_vector = guy_anchor_to_crane_anchor + crane_vector
    guy_angle = Unit.new((crane_tip_to_guy_anchor_vector.to("ft").unitless.to_complex / Complex(@guy_length.to("ft").scalar, 0)).angle, "rad") #C17
    guy_angle_to_crane = crane_angle - guy_angle #C18
    guy_torque_lever = guy_anchor_to_crane_anchor_length * Math::sin(guy_anchor_to_crane_anchor.angle - guy_angle) #C19

    crane_torque_lever = Unit.new("0 in") #C15
    if @anchor_moves_with_mast
      crane_torque_lever = crane_anchor.magnitude * Math::sin(guy_anchor.angle) - guy_angle
    end

    lever_vector = crane_anchor + crane_vector
    lever_length = lever_vector.magnitude
    lever_angle = lever_vector.angle

    line_vector = lever_vector - @mast_pivot_to_pulley
    line_length = line_vector.magnitude
    line_angle = line_vector.angle
    line_angle_to_lever = line_angle - lever_angle #C28 #TODO: This seems backward or at least misnamed
    line_angle_to_crane = line_angle - crane_angle #C29 #TODO: This seems backward or at least misnamed
    line_angle_to_guy = line_angle_to_crane + guy_angle_to_crane #C30

    line_force = static_torque * Math::sin(guy_angle_to_crane) /
      (Math::sin(line_angle_to_crane) * guy_torque_lever + crane_torque_lever * Math::sin(line_angle_to_guy)) #C32

    crane_force = line_force * Math::sin(line_angle_to_guy) / Math::sin(guy_angle_to_crane) #C33

    guy_force = (static_torque - crane_force * crane_torque_lever) / guy_torque_lever

    puts line_force: line_force
    puts crane_force: crane_force
    puts guy_force: guy_force

  end














end
