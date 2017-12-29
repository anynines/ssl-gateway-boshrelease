require 'spec_helper'
require 'httparty'
require 'pp'

include CFHelpers
include BoshHelpers
include ManifestHelpers

describe 'ssl-gateway reachability spec for apps' do
  let(:app_name) { "checker" }

  context 'when service checker apps are pushed' do
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

      it 'it redirects http requests to port 443' do
        response = HTTParty.get("http://#{app_name}.#{ENV["RANDOM_DOMAIN"]}", follow_redirects: false)
        expect(response.headers["location"]).to eq("https://#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}")
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

      it 'it redirects http requests to port 443' do
        response = HTTParty.get("http://#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}", follow_redirects: false)
        expect(response.headers["location"]).to eq("https://#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}")
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

      it 'it redirects http requests to port 443' do
        response = HTTParty.get("http://#{app_name}.#{ENV["REACHABLE_BLACKLIST_DOMAIN"]}", follow_redirects: false)
        expect(response.headers["location"]).to eq("https://#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}")
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
