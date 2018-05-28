# UltraConfig

Ruby gem for application configuration with validation. UltraConfig provides an
all-in-one solution for defining your configuration with default values, 
namespacing and validation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ultra_config'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ultra_config

## Usage

Example Usage: 

```ruby
require 'ultra_config'

ConfigTest = UltraConfig.define do
  config :blank
  config :default, :value

  config :one_of, :this do
    one_of %i[this that]
  end

  config :match, 'this' do
    match /this/
  end

  config :range, 4 do
    range 1, 9
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

# It can then be used like:

ConfigTest.space2.space3.default

```



## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SpyMachine/ultra_config.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).