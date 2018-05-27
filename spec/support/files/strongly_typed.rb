require 'ultra_config'

StronglyTypedTest = UltraConfig.define do
  setting :type_safety, :strong
  
  config :blank
  config :boolean, true
end



