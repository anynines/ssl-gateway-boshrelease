require 'spec_helper'
require 'httparty'

describe 'ssl-gateway deployment with de.a9s.eu blacklisted' do
  let(:gateway_manifest) { 
    b = binding
    b.local_variable_set(:local_ip, `ifconfig | awk '/inet addr/{print substr($2,6)}' | head -1`)
    f.write(ERB.new(File.join(__dir__, "../manifests/reachability.yml.erb")).result(b))
    path.join(__dir__, "../manifests/reachability.yml" )
  }

  let(:app_manifest) { path.join(__dir__, "../support/service-binding-checker/manifest.yml") }

  let(:app_name) { "checker" }

  let(:reachable_blacklist_domain) { "ssltest.com" }

  let(:unreachable_blacklist_domain) { "ssltest2.com" }

  let(:default_app_domain) { "de.a9sapp.eu" }

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
    context 'default_app_domain: de.a9sapp.eu' do
      it 'it is possible to send an http request on port 80 to the default app domain' do
        expect(HTTParty.get("http://#{app_name}.#{default_app_domain}").code) to be("200")
      end

      it 'it is possible to send an https request on port 443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{default_app_domain}:443", :verify => false).code) to be("200")
      end

      it 'it is possible to send an http request on port 4443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{default_app_domain}:4443", :verify => false).code) to be("200")
      end
    end

    context 'blacklist domain with localhost allowed: ssltest.com' do
      it 'it is possible to send an http request on port 80 to the default app domain' do
        expect(HTTParty.get("http://#{app_name}.#{reachable_blacklist_domain}").code) to be("200")
      end

      it 'it is possible to send an https request on port 443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{reachable_blacklist_domain}:443", :verify => false).code) to be("200")
      end

      it 'it is possible to send an http request on port 4443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{reachable_blacklist_domain}:4443", :verify => false).code) to be("200")
      end
    end

    context 'blacklist domain with deny all: ssltest2.com' do
      it 'it is possible to send an http request on port 80 to the default app domain' do
        expect(HTTParty.get("http://#{app_name}.#{unreachable_blacklist_domain}").code) to be("403")
      end

      it 'it is possible to send an https request on port 443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{unreachable_blacklist_domain}:443", :verify => false).code) to be("403")
      end

      it 'it is possible to send an http request on port 4443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{unreachable_blacklist_domain}:4443", :verify => false).code) to be("403")
      end
    end
  end
end