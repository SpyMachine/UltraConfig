require 'ultra_config'

StronglyTypedTest = UltraConfig.define do
  setting :type_safety, :strong

  config :blank
  config :boolean, true

  config(:weak_type, :sym) { type_safety :weak }
end



