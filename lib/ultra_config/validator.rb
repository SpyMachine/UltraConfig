require_relative 'utilities/boolean'

module UltraConfig
  class Validator
    extend Boolean

    class ValidationError < StandardError; end
    class TypeValidationError < ValidationError; end

    def self.validate(old, new, &validation)
      @test_value = new
      type_safety(old) if Settings.type_safety == :strong

      self.instance_eval(&validation) if validation
    ensure
      @test_value = nil
    end

    def self.type_safety(old)
      return if old.nil?
      return if old.is_a?(Boolean) && @test_value.is_a?(Boolean)

      raise TypeValidationError if old.class != @test_value.class
    end

    def self.one_of(list)
      raise ValidationError unless list.include?(@test_value)
    end

    def self.match(regexp)
      raise ValidationError unless regexp.match(@test_value)
    end

    def self.range(low, high)
      raise ValidationError unless (@test_value >= low && @test_value <= high)
    end

    def self.custom(&block)
      raise ValidationError unless block.call(@test_value)
    end
  end
end