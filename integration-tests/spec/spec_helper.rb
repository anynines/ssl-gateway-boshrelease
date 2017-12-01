require 'json'
require 'rspec'

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    Dir.chdir(File.join(__dir__, "../../")) do
      `bosh create-release --force`
      `export RELEASE=$(ls -1t dev_releases/ssl-gateway | sed -n 2p)`
      `bosh upload-release #{ENV["RELEASE"]}`
    end
  end

  config.color = true
  config.fail_fast = true
  config.formatter = :documentation
end
