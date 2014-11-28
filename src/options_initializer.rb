module OptionsInitializer
  extend ActiveSupport::Concern

  module ClassMethods
    def options_initialize(options, &block)
      define_method :initialize do |init_opts|
        options.each do |attribute, attr_opts|
          value = init_opts[attribute]
          required = attr_opts[:required]
          units = attr_opts[:units]

          raise "#{attribute} is required" if required && value.blank?

          if units && value.present?
            begin
              value = Unit(value).to(units)
            rescue
              puts "#{attribute} must be convertible to '#{attr_opts[:units]}'"
              raise
            end
          end

          instance_variable_set("@#{attribute}", value)

          block.call(init_opts) if block
        end
      end
    end
  end
end
