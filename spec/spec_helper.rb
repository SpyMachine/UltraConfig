require 'rspec'
require 'bundler/setup'
require 'ultra_config'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.alias_it_should_behave_like_to :it_is

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
