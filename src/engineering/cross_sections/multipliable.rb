module Engineering
  module CrossSections
    module Multipliable
      extend ActiveSupport::Concern
      included do
        def *(amount)
          Multiplied.new(:section => self, :multiplier => amount)
        end

        def /(amount)
          Multiplied.new(:section => self, :multiplier => 1.0 / amount)
        end

        def -@
          Multiplied.new(:section => self, :multiplier => -1)
        end
      end
    end
  end
end

require_relative "multiplied"
