require 'ultra_config'
require 'pp'

ConfigTest = UltraConfig.define do
  config :blank
  config :default, default: :value

  config(:one_of, default: :this) { one_of %i[this that] }

  config :match, default: 'this' do
    match /this/
  end

  config :range, default: 4 do
    range 1, 9
  end

  config :weak_type, default: :sym do
    type_safety :weak
  end

  config :strong_type, default: :sym do
    type_safety :strong
  end

  config :custom, default: { this: :that } do
    custom { |value| value[:this] == :that }
  end

  config(:sanitized, sanitize: true)

  namespace :space1 do
    config :default, default: :another_value
  end

  namespace :space2 do
    namespace :space3 do
      config :default, default: :a_third_value
    end
  end

  config :a_thing do
    # Transform data
    pre_set_transform { |value| value * 2 }

    # Validation
    custom { |value| value.even? }
  end
end