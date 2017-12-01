require 'json'
require 'rspec'

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    `bosh create-release --force`

    release = 
    `bosh upload-release #{release}`
  end

  config.color = true
  config.fail_fast = true
  config.formatter = :documentation
end
