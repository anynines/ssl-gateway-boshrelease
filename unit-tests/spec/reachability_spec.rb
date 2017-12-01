require 'spec_helper'
require 'httparty'
require 'pp'

describe 'ssl-gateway reachability spec for apps' do
  let(:gateway_manifest) { 
    b = binding
    b.local_variable_set(:local_ip, `ifconfig | awk '/inet addr/{print substr($2,6)}' | head -1`)
    f.write(ERB.new(File.join(__dir__, "../manifests/reachability.yml.erb")).result(b))
    path.join(__dir__, "../manifests/reachability.yml" )
  }

  let(:app_manifest) { path.join(__dir__, "../support/service-binding-checker/manifest.yml") }

  let(:app_name) { "checker" }

  let(:reachable_blacklist_domain) { ENV["REACHABLE_BLACKLIST_DOMAIN"] }

  let(:unreachable_blacklist_domain) { ENV["UNREACHABLE_BLACKLIST_DOMAIN"] }

  let(:default_app_domain) { ENV["DEFAULT_APP_DOMAIN"] }

  let(:random_domain) { ENV["RANDOM_DOMAIN"] }

  before(:context) do
    # `bosh deploy -d ssl-gateway #{gateway_manifest} -l #{ENV('IAAS_CONFIG')} -l #{ENV('EXTERNAL_SECRETS')} -o #{ENV('OPS')}`
    # `cf login -o ssl-gateway-unit-tests -s test -u #{ENV('CF_USERNAME')} -p #{ENV('CF_PASSWORD')} --skip-ssl-validation`

    # `export PORT=80 && cf push #{app_manifest} #{app_name}`
    # `export PORT=443 && cf push #{app_manifest} #{app_name}`
    # `export PORT=4443 && cf push #{app_manifest} #{app_name}`

    # `export PORT=80 && cf push #{app_manifest} #{app_name} -d #{reachable_blacklist_domain}`
    # `export PORT=443 && cf push #{app_manifest} #{app_name} -d #{reachable_blacklist_domain}`
    # `export PORT=4443 && cf push #{app_manifest} #{app_name} -d #{reachable_blacklist_domain}`

    # `export PORT=80 && cf push #{app_manifest} #{app_name} -d #{unreachable_blacklist_domain}`
    # `export PORT=443 && cf push #{app_manifest} #{app_name} -d #{unreachable_blacklist_domain}`
    # `export PORT=4443 && cf push #{app_manifest} #{app_name} -d #{unreachable_blacklist_domain}`
  end

  after(:context) do
    # `bosh deploy -d ssl-gateway #{ENV('SSL_GATEWAY_MANIFEST')} -l #{ENV('IAAS_CONFIG')} -l #{ENV('EXTERNAL_SECRETS')} -o #{ENV('OPS')}`
    # `cf delete #{app_name}.#{reachable_blacklist_domain}`
    # `cf delete #{app_name}.#{unreachable_blacklist_domain}`
    # `cf delete #{app_name}.#{default_app_domain}`
  end

  context 'when a ssl-gateway is deployed with service checker apps' do
    context "random_domain #{ENV["RANDOM_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the default app domain' do
        expect(HTTParty.get("http://#{app_name}.#{random_domain}").code == 200)
      end

      it 'it is possible to send a https request on port 443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{random_domain}:443", :verify => false).code == 200)
      end

      it 'it is possible to send a http request on port 4443 to the default app domain' do
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

    context "blacklist domain with localhost allowed #{ENV["REACHABLE_BLACKLIST_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the default app domain' do
        expect(HTTParty.get("http://#{app_name}.#{reachable_blacklist_domain}").code == 200)
      end

      it 'it is possible to send a https request on port 443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{reachable_blacklist_domain}:443", :verify => false).code == 200)
      end

      it 'it is possible to send a http request on port 4443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{reachable_blacklist_domain}:4443", :verify => false).code == 200)
      end
    end

    context "blacklist domain with deny all #{ENV["UNREACHABLE_BLACKLIST_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the default app domain' do
        expect(HTTParty.get("http://#{app_name}.#{unreachable_blacklist_domain}").code == 403)
      end

      it 'it is possible to send a https request on port 443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{unreachable_blacklist_domain}:443", :verify => false).code == 403)
      end

      it 'it is possible to send a http request on port 4443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{unreachable_blacklist_domain}:4443", :verify => false).code == 403)
      end
    end
  end
end
