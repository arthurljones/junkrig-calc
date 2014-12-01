require "active_support/concern"
require "active_support/core_ext"

module OptionsInitializer
  extend ActiveSupport::Concern

  module ClassMethods
    def options_initialize(attributes, &block)
      define_method :initialize do |new_args|
        new_args = new_args.clone
        attributes.each do |attribute_name, options|
          value = new_args[attribute_name] || options[:default]

          raise "#{attribute_name} is required for #{self.class.name}" if options[:required] && value.blank?

          units = options[:units]
          if units && value.present?
            begin
              value = Unit(value).to(units)
            rescue ArgumentError => e
              e.message = "#{e.message} (#{attribute_name})"
              raise e
            end
          end

          #:write option is default true, so we only skip writing if the variable is specifically false, not just false-like
          instance_variable_set("@#{attribute_name}", value) unless options[:write] == false
          new_args[attribute_name] = value

        end

        instance_exec(new_args, &block) if block
      end
    end
  end
end
