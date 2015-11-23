class Constants
  class << self
    def all
      unless @all
        @all = load_yaml_data_file("constants.yml")
        @all.each { |key, val| @all[key] = Unit.new(val) rescue val }
      end
      @all
    end

    def method_missing(meth, *args, &block)
      all.include?(meth) ? all[meth] : super
    end

    def respond_to_missing?(method_name, include_private = false)
      all.include?(meth) || super
    end
  end
end
