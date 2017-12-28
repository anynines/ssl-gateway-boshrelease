require 'json'
require 'rspec'

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  include BoshHelpers
  include CFHelpers

  config.color = true
  config.fail_fast = true
  config.formatter = :documentation
end
