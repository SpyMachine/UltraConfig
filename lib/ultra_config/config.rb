require_relative 'validation'
require_relative 'settings'

module UltraConfig
  class Config
    include Validation

    attr_reader :value

    def initialize(options = {}, &block)
      @config_block = block

      @value = options[:default].nil? ? nil : options[:default]
      @sanitize = options[:sanitize] || false
      @error_msg = options[:error_msg]
    end

    def value=(value)
      @intermediate_value = value
      self.instance_eval(&@config_block) if @config_block
      type_safety(Settings.type_safety) unless @type_safety_checked
      @value = @intermediate_value
    rescue UltraConfig::Validation::ValidationError
      raise UltraConfig::Validation::ValidationError.new(msg: @error_msg)
    ensure
      @type_safety_checked = false
      @intermediate_value = nil
    end

    def set(&block)
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