require 'json'
require 'rspec'

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  include BoshHelpers

  config.before(:suite) do
    BoshHelpers::create_dev_release
    BoshHelpers::upload_last_dev_release
  end

  config.after(:suite) do
    BoshHelpers::cleanup_all
  end

  config.color = true
  config.fail_fast = true
  config.formatter = :documentation
end
