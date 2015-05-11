module ExportHelper
    module_function
    def generate_csv(objects, output_format)
        objects = Array(objects)
        output_format.collect do |output|
            row_text = ""
            property = output.first
            if property
                units = output.last
                row_text = "#{property.to_s.titleize}"
                row_text += " (#{units})" if units
                row_text += ","
                row_text += objects.collect do |object|
                    value = object.send(property)
                    value = value.to(units) if units && value.respond_to?(:to)
                    value = value.scalar if value.respond_to?(:scalar)
                    value.to_f
                end.join(",")
            end
            row_text
        end.join("\n")
    end
end
