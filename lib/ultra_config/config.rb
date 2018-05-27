require_relative 'validator'
require_relative 'settings'

module UltraConfig
  class Config
    attr_reader :value

    def initialize(default_value, &block)
      @validation = block
      self.value=(default_value)
    end

    def value=(value)
      validate(value)

      @value = value
    end

    def validate(new_value)
      Validator.validate(@value, new_value, &@validation)
    end
  end
end