require 'logger'

require_relative 'config'

module UltraConfig
  class Namespace
    class ObjectNotFoundError < StandardError; end

    attr_accessor :logger
    attr_reader :objects

    def initialize(parents = [], &block)
      @configuration = [block]
      @parents = parents

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
      @objects[name] = Namespace.new(@parents + [name], &block)
      define_singleton_method(name) { @objects[name] }
    end

    def config(name, options = {}, &block)
      @objects[name] = Config.new(name, @parents, options, &block)
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
            hash[name] = object.value.nil? ? nil : '*****'
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

    private

    def logger
      @logger ||= (logger || Logger.new(IO::NULL))
    end
  end
end