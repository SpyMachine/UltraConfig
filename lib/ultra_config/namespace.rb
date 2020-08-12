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

    def merge_hash!(hash, parents = [])
      hash.each do |k, v|
        options = send_chain(parents)
        if options.objects[k.to_sym].is_a?(Config)
          options.send("#{k}=", v) unless v.nil?
        elsif options.objects[k.to_sym].is_a?(Namespace)
          merge_hash!(v, parents + [k])
        else
          logger.warn { "received an unknown config #{k} with value #{v} and parents: #{parents}" }
        end
      end

      self
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

    # Send a chain of methods to an object
    # @param arr [Array] list of methods to send to object
    # @return [Object] result of method chain
    def send_chain(arr)
      arr.inject(self) {|obj, arr| obj.send(arr) }
    end

    def logger
      @logger ||= (logger || Logger.new(IO::NULL))
    end
  end
end