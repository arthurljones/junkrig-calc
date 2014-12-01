RubyUnits::Unit.define('long-ton') do |ton|
  ton.definition = RubyUnits::Unit.new('2240 lbs')
  ton.aliases = %w{ltn long-tons}
end
