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
        new_args ||= {}
        new_args = new_args.clone
        attributes.each do |attribute_name, options|
          default = options[:default]
          klass = options[:class]

          value = new_args[attribute_name] || default

          #Required by default, only a literal false value means not required
          required = options[:required] != false
          raise "#{attribute_name} is required for #{self.class.name}" if required && value.blank? && value != default

          units = options[:units]
          if units
            raise ArgumentError.new("You may not specify :units and :class at the same time") if klass
            klass = Unit
          end

          if !value.nil? && klass && !(klass === value)
            constructor = options[:constructor] || :new
            begin
              #ap [attribute_name, klass.name, constructor, value]
              value = klass.send(constructor, value)
              if units
                value = value.to(units)
              end
            rescue => e
              raise e, "#{e.message} (#{self.class.name}.@#{attribute_name})", e.backtrace
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
