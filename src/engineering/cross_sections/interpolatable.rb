module Engineering
  module CrossSections
    module Interpolatable
      extend ActiveSupport::Concern
      included do
        def interpolate(other, parameter)
          raise "Cannot interpolate between #{self.class.name} and #{other.class.name} objects" unless self.class == other.class

          options = self.class.options_initialize_attributes.keys.each_with_object({}) do |attr_name, result|
            this_portion = send(attr_name) * (1 - parameter)
            other_portion = other.send(attr_name) * parameter
            result[attr_name] = this_portion + other_portion
          end

          self.class.new(options)
        end
      end
    end
  end
end

require_relative "multiplied"
