require 'spec_helper'
require 'httparty'
require 'pp'

describe 'ssl-gateway reachability spec for apps' do
  let(:app_name) { 
    ENV["APP_NAME"] = "checker"
    ENV["APP_NAME"] 
  }

  let(:reachable_ssl_blacklist_domain) { ENV["REACHABLE_SSL_BLACKLIST_DOMAIN"] }

  let(:unreachable_ssl_blacklist_domain) { ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"] }

  let(:reachable_blacklist_domain) { ENV["REACHABLE_BLACKLIST_DOMAIN"] }

  let(:unreachable_blacklist_domain) { ENV["UNREACHABLE_BLACKLIST_DOMAIN"] }

  let(:default_app_domain) { ENV["DEFAULT_APP_DOMAIN"] }

  let(:random_domain) { ENV["RANDOM_DOMAIN"] }

  before(:all) do
    b = binding
    b.local_variable_set(:local_ip, ENV["LOCALHOST_IP"])

    manifest_path = File.join(__dir__, "../manifests/reachability.yml")

    File.open(manifest_path, "w") do |f|  
      f.write(ERB.new(File.read(File.join(__dir__, "../manifests/reachability.yml.erb"))).result(b))
    end

    Dir.chdir(File.join(__dir__, "../../")) do
      if ENV['OPS_FILE']
        `bosh deploy -d ssl-gateway #{manifest_path} -l #{ENV['IAAS_CONFIG']} -l #{ENV['EXTERNAL_SECRETS']} -o #{ENV['OPS_FILE']}`
      else 
        `bosh deploy -d ssl-gateway #{manifest_path} -l #{ENV['IAAS_CONFIG']} -l #{ENV['EXTERNAL_SECRETS']}`
      end

      `bosh task`
      `cf login -o #{ENV['CF_ORG']} -s #{ENV['CF_SPACE']} -u #{ENV['CF_USERNAME']} -p #{ENV['CF_PASSWORD']} --skip-ssl-validation`
    end
    
    Dir.chdir(File.join(__dir__, "support/service-binding-checker")) do
      `export PORT=80 && cf push #{ENV["APP_NAME"]}`
      `export PORT=443 && cf push #{ENV["APP_NAME"]}`
      `export PORT=4443 && cf push #{ENV["APP_NAME"]}`

      `export PORT=80 && cf push #{ENV["APP_NAME"]} -d #{ENV["REACHABLE_BLACKLIST_DOMAIN"]}`

      `export PORT=80 && cf push #{ENV["APP_NAME"]} -d #{ENV["UNREACHABLE_BLACKLIST_DOMAIN"]}`

      `export PORT=80 && cf push #{ENV["APP_NAME"]} -d #{ENV["REACHABLE_SSL_BLACKLIST_DOMAIN"]}`
      `export PORT=443 && cf push #{ENV["APP_NAME"]} -d #{ENV["REACHABLE_SSL_BLACKLIST_DOMAIN"]}`
      `export PORT=4443 && cf push #{ENV["APP_NAME"]} -d #{ENV["REACHABLE_SSL_BLACKLIST_DOMAIN"]}`

      `export PORT=80 && cf push #{app_name} -d #{ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"]}`
      `export PORT=443 && cf push #{app_name} -d #{ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"]}`
      `export PORT=4443 && cf push #{app_name} -d #{ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"]}`
    end
  end

  after(:all) do
    `cf delete #{ENV["APP_NAME"]}`
  end

  context 'when a ssl-gateway is deployed with service checker apps' do
    context "reachable blacklist domain #{ENV["REACHABLE_BLACKLIST_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the reachable blacklist domain' do
        expect(HTTParty.get("http://#{app_name}.#{reachable_blacklist_domain}").code == 200)
      end
    end

    context "unreachable blacklist domain #{ENV["UNREACHABLE_BLACKLIST_DOMAIN"]}" do
      it 'it should not be possible to send a http request on port 80 to the unreachable blacklist domain' do
        expect(HTTParty.get("http://#{app_name}.#{unreachable_blacklist_domain}").code == 200)
      end
    end

    context "random_domain #{ENV["RANDOM_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the random domain' do
        expect(HTTParty.get("http://#{app_name}.#{random_domain}").code == 200)
      end

      it 'it is possible to send a https request on port 443 to the random domain' do
        expect(HTTParty.get("https://#{app_name}.#{random_domain}:443", :verify => false).code == 200)
      end

      it 'it is possible to send a http request on port 4443 to the random domain' do
        expect(HTTParty.get("https://#{app_name}.#{random_domain}:4443", :verify => false).code == 200)
      end
    end

    context "default_app_domain #{ENV["DEFAULT_APP_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the default app domain' do
        expect(HTTParty.get("http://#{app_name}.#{default_app_domain}").code == 200)
      end

      it 'it is possible to send a https request on port 443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{default_app_domain}:443", :verify => false).code == 200)
      end

      it 'it is possible to send a http request on port 4443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{default_app_domain}:4443", :verify => false).code == 200)
      end
    end

    context "blacklist domain with ssl and localhost allowed #{ENV["REACHABLE_BLACKLIST_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the reachable blacklist domain' do
        expect(HTTParty.get("http://#{app_name}.#{reachable_blacklist_domain}").code == 200)
      end

      it 'it is possible to send a https request on port 443 to the reachable blacklist domain' do
        expect(HTTParty.get("https://#{app_name}.#{reachable_blacklist_domain}:443", :verify => false).code == 200)
      end

      it 'it is possible to send a http request on port 4443 to thereachable blacklist domain' do
        expect(HTTParty.get("https://#{app_name}.#{reachable_blacklist_domain}:4443", :verify => false).code == 200)
      end
    end

    context "blacklist domain with ssl and deny all #{ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"]}" do
      it 'it should not be possible to send a http request on port 80 to the unreachable ssl blacklist domain' do
        expect(HTTParty.get("http://#{app_name}.#{unreachable_ssl_blacklist_domain}").code == 403)
      end

      it 'it should not be possible to send a https request on port 443 to the unreachable ssl blacklist domain' do
        expect(HTTParty.get("https://#{app_name}.#{unreachable_ssl_blacklist_domain}:443", :verify => false).code == 403)
      end

      it 'it should not be possible to send a http request on port 4443 to the unreachable ssl blacklist domain' do
        expect(HTTParty.get("https://#{app_name}.#{unreachable_ssl_blacklist_domain}:4443", :verify => false).code == 403)
      end
    end
  end
end
