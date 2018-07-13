require_relative 'config'

module UltraConfig
  class Namespace
    class ObjectNotFoundError < StandardError; end

    attr_reader :objects

    def initialize(&block)
      @configuration = [block]
      reset
    end

    def extend(&block)
      @configuration << block
      self.instance_eval(&block)
    end

    def setting(name, value)
      Settings.set(name, value)
    end

    def namespace(name, &block)
      @objects[name] = Namespace.new(&block)
      define_singleton_method(name) { @objects[name] }
    end

    def config(name, default = nil, options = {}, &block)
      @objects[name] = Config.new(default, options, &block)
      define_singleton_method("#{name}=") { |value| @objects[name].value = value }
      define_singleton_method(name) { @objects[name].value }
    end

    def helper(name, &block)
      define_singleton_method(name, &block)
    end

    def reset
      @objects = {}
      @configuration.each { |config| self.instance_eval(&config) }
    end

    def to_h
      hash = {}
      @objects.each do |name, object|
        if object.is_a?(Config)
          hash[name] = object.value
        else
          hash[name] = object.to_h
        end
      end

      hash
    end

    def to_sanitized_h
      hash = {}
      @objects.each do |name, object|
        if object.is_a?(Config)
          if object.sanitize?
            hash[name].nil? ? nil : hash[name] = '*****'
          else
            hash[name] = object.value
          end
        else
          hash[name] = object.to_sanitized_h
        end
      end

      hash
    end

    def method_missing(m)
      raise ObjectNotFoundError
    end
  end
end