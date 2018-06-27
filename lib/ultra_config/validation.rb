require_relative 'utilities/boolean'

module UltraConfig
  module Validation
    include Boolean

    class ValidationError < StandardError; end
    class TypeValidationError < ValidationError; end

    def type_safety(type)
      @type_safety_checked = true

      return unless type == :strong
      return if @value.nil?
      return if @value.is_a?(Boolean) && @intermediate_value.is_a?(Boolean)

      raise TypeValidationError if @value.class != @intermediate_value.class
    end

    def one_of(list)
      raise ValidationError unless list.include?(@intermediate_value)
    end

    def match(regexp)
      raise ValidationError unless regexp.match(@intermediate_value)
    end

    def range(low, high)
      raise ValidationError unless (@intermediate_value >= low && @intermediate_value <= high)
    end

    def custom(&block)
      raise ValidationError unless block.call(@intermediate_value)
    end
  end
end