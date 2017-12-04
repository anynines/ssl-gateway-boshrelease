require 'json'
require 'rspec'

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  include BoshHelpers
  include CFHelpers

  config.before(:suite) do
    BoshHelpers::create_dev_release
    BoshHelpers::upload_last_dev_release
    CFHelpers::cf_login(ENV["CF_USERNAME"], ENV["CF_PASSWORD"])
    CFHelpers::create_org("ssl-gateway-tests")
    CFHelpers::create_space("ssl-gateway-tests", "integration")
    CFHelpers::target("ssl-gateway-tests", "integration")
  end

  config.after(:suite) do
    CFHelpers::delete_org("ssl-gateway-tests")
    BoshHelpers::cleanup_all
  end

  config.color = true
  config.fail_fast = true
  config.formatter = :documentation
end
