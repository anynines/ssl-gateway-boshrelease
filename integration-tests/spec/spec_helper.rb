require 'json'
require 'rspec'

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    Dir.chdir(File.join(__dir__, "../../../")) do
      `bosh create-release --force`
      ENV["RELEASE"] = `ls -1t dev_releases/ssl-gateway | sed -n 2p`
      `bosh upload-release dev_releases/ssl-gateway/#{ENV["RELEASE"]}`
      `bosh task`
    end
  end

  config.after(:suite) do
    `bosh clean-up --all`
  end

  config.color = true
  config.fail_fast = true
  config.formatter = :documentation
end
