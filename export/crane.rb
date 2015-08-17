require_relative "../boilerplate"
require "crane"
require "export_helper"

crane = Crane.new({})

require 'ruby-prof'

RubyProf.start

objects = (0..90).step(1).map do |angle|
  crane.calculate(Unit.new(angle, "deg"))
end

result = RubyProf.stop
printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT)
#puts
#puts
#puts

output_format = [
    [:angle, "deg", ->(x){x[:mast_angle]}],
    [:line_length, "ft", ->(x){x[:line_length]}],
    [:line_force, "lbs", ->(x){x[:line_force]}],
    [:crane_force, "lbs", ->(x){x[:crane_force]}],
    [:guy_force, "lbs", ->(x){x[:guy_force]}],
    [:guy_anchor_x, "ft", ->(x){x[:guy_anchor].x}],
    [:guy_anchor_y, "ft", ->(x){x[:guy_anchor].y}],
    [:crane_tip_x, "ft", ->(x){x[:crane_tip].x}],
    [:crane_tip_y, "ft", ->(x){x[:crane_tip].y}],
    [:crane_pivot_x, "ft", ->(x){x[:crane_pivot].x}],
    [:crane_pivot_y, "ft", ->(x){x[:crane_pivot].y}],
    [:pulley_x, "ft", ->(x){x[:pulley].x}],
    [:pulley_y, "ft", ->(x){x[:pulley].y}],
    [:mast_pivot_x, "ft", ->(x){x[:mast_pivot].x}],
    [:mast_pivot_y, "ft", ->(x){x[:mast_pivot].y}],
]

puts ExportHelper.generate_csv(objects, output_format)
