require_relative 'utilities/boolean'

module UltraConfig
  class Validator
    extend Boolean

    class ValidationError < StandardError; end
    class TypeValidationError < ValidationError; end

    def self.validate(old, new, &validation)
      @old_value = old
      @test_value = new

      return if @test_value.nil?

      self.instance_eval(&validation) if validation

      type_safety(Settings.type_safety) unless @explicit_type_safety
    ensure
      @test_value = nil
      @old_value = nil
      @explicit_type_safety = false
    end

    def self.type_safety(type)
      @explicit_type_safety = true
      return unless type == :strong

      return if @old_value.nil?
      return if @old_value.is_a?(Boolean) && @test_value.is_a?(Boolean)

      raise TypeValidationError if @old_value.class != @test_value.class
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