module MathProxy
  private
  def math_proxy(name, klass)
    own_class = self

    define_method("method_missing_with_#{name}") do |meth, *args, &block|
      assignment = meth =~ /\A[\*\+\-\/]=\Z/
      meth = meth[0] if assignment
      proxy = send(name)

      if proxy.respond_to?(meth)
        args = args.map { |arg| own_class === arg ? arg.send(name) : arg }
        result = proxy.send(meth, *args, &block)
        if assignment
          send("#{name}=", result)
          result = self
        elsif klass === result
          result = own_class.new(result)
        end
        result
      else
        send("method_missing_without_#{name}", meth, *args, &block)
      end
    end
    alias_method_chain(:method_missing, name)

    define_method("respond_to_missing_with_#{name}?") do |meth, include_private = false|
      send(name).respond_to?(meth, include_private) || send("respond_to_missing_without_#{name}?", meth, include_private)
    end
    alias_method_chain(:respond_to_missing?, name)
  end
end