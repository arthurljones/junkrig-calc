module OptionsInitializer
  extend ActiveSupport::Concern

  module ClassMethods
    def options_initialize(options, &block)
      define_method :initialize do |init_opts|
        options.each do |attribute, attr_opts|
          value = init_opts[attribute]
          required = attr_opts[:required]
          units = attr_opts[:units]
          value ||= options[:default]

          raise "#{attribute} is required" if required && value.blank?

          if units && value.present?
            begin
              value = init_opts[attribute] = Unit(value).to(units)
            rescue ArgumentError => e
              e.message = "#{e.message} (#{attribute})"
              raise e
            end
          end

          #:write option is default true, so we only skip writing if the variable is specifically false, not just false-like
          instance_variable_set("@#{attribute}", value) unless options[:write] == false

        end

        instance_exec(init_opts, &block) if block
      end
    end
  end
end
