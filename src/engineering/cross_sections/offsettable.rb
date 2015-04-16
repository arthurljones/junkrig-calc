module Engineering
  module CrossSections
    module Offsettable
      extend ActiveSupport::Concern
      included do
        def offset(amount)
          Offset.new(:section => self, :offset => amount)
        end
      end
    end
  end
end

require_relative "offset"
