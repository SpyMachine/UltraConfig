require_relative 'validation'
require_relative 'settings'

module UltraConfig
  class Config
    include Validation

    attr_reader :value

    def initialize(options = {}, &block)
      @config_block = block
      @value = options[:default] || nil
      @sanitize = options[:sanitize] || false
    end

    def value=(value)
      @intermediate_value = value
      self.instance_eval(&@config_block) if @config_block
      type_safety(Settings.type_safety) unless @type_safety_checked
      @value = @intermediate_value
    ensure
      @type_safety_checked = false
      @intermediate_value = nil
    end

    def pre_set_transform(&block)
      @intermediate_value = yield(@intermediate_value)
    end

    def sanitize?
      @sanitize
    end

    def to_s
      "\"#{@value.to_s}\""
    end
  end
end