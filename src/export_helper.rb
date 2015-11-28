module ExportHelper
  module_function
  def generate_csv(objects, output_format)
    objects = Array(objects)
    output_format.collect do |output|
      row_text = ""
      options = output.pop || {}
      raise ArgumentError.new("Options are not a hash: #{options}") unless Hash === options
      target_units = options[:units]
      last_property = nil
      values = nil

      if output.any?
        values = objects.collect do |object|
          value = output.reduce(object) do |result, property|
            last_property = property
            begin
              result.send(property)
            rescue => error
              puts "Error getting property #{property} on object #{object}: #{error.message}"
              raise error
            end
          end
          value = value.to(target_units || Unit.new(1)) if value.respond_to?(:to)
          value = value.scalar if value.respond_to?(:scalar)
          value.to_f
        end
      end

      row_text = "#{(options[:label] || last_property).to_s.titleize}"
      row_text += " (#{target_units})" if target_units
      row_text += ",#{values.join(",")}" if values.present?
      row_text
    end.join("\n")
  end
end
