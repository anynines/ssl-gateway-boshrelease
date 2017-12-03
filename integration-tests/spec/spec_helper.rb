require 'json'
require 'rspec'

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    BoshHelper::create_dev_release
    BoshHelper::upload_last_dev_release
  end

  config.after(:suite) do
    BoshHelper::cleanup_all
  end

  config.color = true
  config.fail_fast = true
  config.formatter = :documentation
end
