require_relative 'config'

module UltraConfig
  class Namespace
    def initialize(&block)
      @configuration = block
      reset
    end

    def setting(name, value)
      Settings.set(name, value)
    end

    def namespace(name, &block)
      @objects[name] = Namespace.new(&block)
    end

    def config(name, default = nil, &block)
      @objects[name] = Config.new(default, &block)
    end

    def helper(name, &block)
      define_singleton_method(name, &block)
    end

    def method_missing(m, *args)
      if m.to_s.end_with?('=')
        @objects[m.to_s[0...-1].to_sym].value=(args[0])
      else
        @objects[m].is_a?(Config) ? @objects[m].value : @objects[m]
      end
    end

    def reset
      @objects = {}
      self.instance_eval(&@configuration)
    end

    def to_s
      objs = []

      output = '{ '
      @objects.each { |name, object| objs << "#{name}: #{object.to_s}" }
      output << objs.join(', ')
      output << ' }'
    end
  end
end