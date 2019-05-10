require 'spec_helper'
require "bundler/setup"

require "webview"

$gui_env = if ENV['CI'] && ENV['TRAVIS']
  false
else
  true
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
end
