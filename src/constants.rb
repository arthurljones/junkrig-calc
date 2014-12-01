class Constants
  class << self
    def all
      unless @all
        dir = File.expand_path(File.dirname(__FILE__))
        @all = YAML.load_file(File.join(dir, "..", "constants.yml")).with_indifferent_access
        @all.each { |key, val| @all[key] = Unit(val) rescue val }
      end
      @all
    end

    def method_missing(meth, *args, &block)
      @all.include?(meth) ? @all[meth] : super
    end

    def respond_to_missing?(method_name, include_private = false)
      @all.include?(meth) || super
    end
  end
end
