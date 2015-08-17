module ExportHelper
    module_function
    def generate_csv(objects, output_format)
        objects = Array(objects)
        output_format.collect do |output|
            row_text = ""
            property = output.shift
            if property
                units = output.shift
                getter = output.shift
                row_text = "#{property.to_s.titleize}"
                row_text += " (#{units})" if units
                row_text += ","
                row_text += objects.collect do |object|
                    begin
                        if getter
                            value = getter.call(object)
                        else
                            value = object.send(property)
                        end
                    rescue => error
                        puts "Error getting property #{property} on object #{object}: #{error.message}"
                        raise error
                    end
                    target_units = units || Unit.new(1)
                    value = value.to(target_units) if value.respond_to?(:to)
                    value = value.scalar if value.respond_to?(:scalar)
                    value.to_f
                end.join(",")
            end
            row_text
        end.join("\n")
    end
end
