module Engineering
  module CrossSections
    module Compositable
      extend ActiveSupport::Concern
      included do
        def +(section)
          Composite.new(:sections => [self, section])
        end

        def -(section)
          Composite.new(:sections => [self, -section])
        end
      end
    end
  end
end

require_relative "composite"
