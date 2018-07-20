require 'ultra_config'

StronglyTypedTest = UltraConfig.define do
  setting :type_safety, :strong

  config :blank
  config :boolean, default: true

  config(:weak_type, default: :sym) { type_safety :weak }
end



