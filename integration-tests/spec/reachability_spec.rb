require 'spec_helper'
require 'httparty'
require 'pp'

describe 'ssl-gateway reachability spec for apps' do
  let(:app_name) { "checker" }
  let(:manifest) { "reachability.yml" }

  before(:all) do
    properties = {
      :release_version => ENV["RELEASE"],
      :local_ip => ENV["LOCALHOST_IP"]
    }

    ManifestHelpers::render_manifest(manifest, properties)
    BoshHelper::deploy(manifest, ENV['IAAS_CONFIG'], ENV['EXTERNAL_SECRETS'], ENV['OPS_FILE'])
    CFHelpers::login(ENV['CF_USERNAME'], ENV['CF_PASSWORD'], ENV['CF_SPACE'], ENV['CF_ORG'])
    
    CFHelpers::push_checker_app(app_name, 80)
    CFHelpers::push_checker_app(app_name, 443)
    CFHelpers::push_checker_app(app_name, 4443)

    CFHelpers::push_checker_app(app_name, 80, ENV["REACHABLE_BLACKLIST_DOMAIN"])
    CFHelpers::push_checker_app(app_name, 80, ENV["UNREACHABLE_BLACKLIST_DOMAIN"])

    CFHelpers::push_checker_app(app_name, 80, ENV["REACHABLE_SSL_BLACKLIST_DOMAIN"])
    CFHelpers::push_checker_app(app_name, 443, ENV["REACHABLE_SSL_BLACKLIST_DOMAIN"])
    CFHelpers::push_checker_app(app_name, 4443, ENV["REACHABLE_SSL_BLACKLIST_DOMAIN"])

    CFHelpers::push_checker_app(app_name, 80, ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"])
    CFHelpers::push_checker_app(app_name, 443, ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"])
    CFHelpers::push_checker_app(app_name, 4443, ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"])
  end

  after(:all) do
    CFHelpers::delete_app(app_name)
    BoshHelper::cleanup_all
  end

  context 'when a ssl-gateway is deployed with service checker apps' do
    context "reachable blacklist domain #{ENV["REACHABLE_BLACKLIST_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the reachable blacklist domain' do
        expect(HTTParty.get("http://#{app_name}.#{ENV["REACHABLE_BLACKLIST_DOMAIN"]}").code == 200)
      end
    end

    context "unreachable blacklist domain #{ENV["UNREACHABLE_BLACKLIST_DOMAIN"]}" do
      it 'it should not be possible to send a http request on port 80 to the unreachable blacklist domain' do
        expect(HTTParty.get("http://#{app_name}.#{ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"]}").code == 200)
      end
    end

    context "random_domain #{ENV["RANDOM_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the random domain' do
        expect(HTTParty.get("http://#{app_name}.#{ENV["RANDOM_DOMAIN"]}").code == 200)
      end

      it 'it is possible to send a https request on port 443 to the random domain' do
        expect(HTTParty.get("https://#{app_name}.#{ENV["RANDOM_DOMAIN"]}:443", :verify => false).code == 200)
      end

      it 'it is possible to send a http request on port 4443 to the random domain' do
        expect(HTTParty.get("https://#{app_name}.#{ENV["RANDOM_DOMAIN"]}:4443", :verify => false).code == 200)
      end
    end

    context "default_app_domain #{ENV["DEFAULT_APP_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the default app domain' do
        expect(HTTParty.get("http://#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}").code == 200)
      end

      it 'it is possible to send a https request on port 443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}:443", :verify => false).code == 200)
      end

      it 'it is possible to send a http request on port 4443 to the default app domain' do
        expect(HTTParty.get("https://#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}:4443", :verify => false).code == 200)
      end
    end

    context "blacklist domain with ssl and localhost allowed #{ENV["REACHABLE_BLACKLIST_DOMAIN"]}" do
      it 'it is possible to send a http request on port 80 to the reachable blacklist domain' do
        expect(HTTParty.get("http://#{app_name}.#{ENV["REACHABLE_BLACKLIST_DOMAIN"]}").code == 200)
      end

      it 'it is possible to send a https request on port 443 to the reachable blacklist domain' do
        expect(HTTParty.get("https://#{app_name}.#{ENV["REACHABLE_BLACKLIST_DOMAIN"]}:443", :verify => false).code == 200)
      end

      it 'it is possible to send a http request on port 4443 to thereachable blacklist domain' do
        expect(HTTParty.get("https://#{app_name}.#{ENV["REACHABLE_BLACKLIST_DOMAIN"]}:4443", :verify => false).code == 200)
      end
    end

    context "blacklist domain with ssl and deny all #{ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"]}" do
      it 'it should not be possible to send a http request on port 80 to the unreachable ssl blacklist domain' do
        expect(HTTParty.get("http://#{app_name}.#{ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"]}").code == 403)
      end

      it 'it should not be possible to send a https request on port 443 to the unreachable ssl blacklist domain' do
        expect(HTTParty.get("https://#{app_name}.#{ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"]}:443", :verify => false).code == 403)
      end

      it 'it should not be possible to send a http request on port 4443 to the unreachable ssl blacklist domain' do
        expect(HTTParty.get("https://#{app_name}.#{ENV["UNREACHABLE_SSL_BLACKLIST_DOMAIN"]}:4443", :verify => false).code == 403)
      end
    end
  end
end
