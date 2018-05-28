require 'ultra_config'

ConfigTest = UltraConfig.define do
  config :blank
  config :default, :value

  config(:one_of, :this) { one_of %i[this that] }

  config :match, 'this' do
    match /this/
  end

  config :range, 4 do
    range 1, 9
  end

  config :weak_type, :sym do
    type_safety :weak
  end

  config :strong_type, :sym do
    type_safety :strong
  end

  config :custom, { this: :that } do
    custom { |value| value[:this] == :that }
  end

  namespace :space1 do
    config :default, :another_value
  end

  namespace :space2 do
    namespace :space3 do
      config :default, :a_third_value
    end
  end
end




