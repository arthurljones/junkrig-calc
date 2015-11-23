require "active_support/concern"
require "ruby-units"

module OptionsInitializer
  extend ActiveSupport::Concern

  module ClassMethods
    def options_initialize(attributes, &block)
      attributes.each do |attribute_name, options|
        attr_reader attribute_name unless options[:write] == false
      end

      define_singleton_method :options_initialize_attributes do
        attributes
      end

      define_method :initialize do |new_args|
        new_args = new_args.clone
        attributes.each do |attribute_name, options|
          value = new_args[attribute_name] || options[:default]

          #Required by default, only a literal false value means not required
          required = options[:required] != false
          raise "#{attribute_name} is required for #{self.class.name}" if required && value.blank?

          units = options[:units]
          if units && value.present?
            begin
              value = Unit.new(value).to(units)
            rescue ArgumentError => e
              raise e, "#{e.message} (#{attribute_name})", e.backtrace
            end
          end

          constructor = options[:constructor]
          if constructor
            begin
              value = constructor.call(value)
            rescue ArgumentError => e
              raise e, "#{e.message} (#{attribute_name})", e.backtrace
            end
          end

          #write is true by default, only a literal false value does not write
          instance_variable_set("@#{attribute_name}", value) unless options[:write] == false
          new_args[attribute_name] = value

        end

        instance_exec(new_args, &block) if block
      end
    end
  end
end
