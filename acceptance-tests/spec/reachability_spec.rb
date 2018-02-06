require 'spec_helper'
require 'httparty'
require 'socket'
require 'pp'

include CFHelpers
include BoshHelpers
include ManifestHelpers

describe 'ssl-gateway reachability spec for apps' do
  let(:app_name) { "checker" }

  context 'when service checker apps are pushed' do
    context "when the https redirect is enabled" do
      it "should return 301 moved permanetely for all apps on port 80" do
        expect(Net::HTTP.get_response(URI("http://#{app_name}.#{ENV["REACHABLE_DOMAIN"]}")) == 301)
        expect(Net::HTTP.get_response(URI("http://#{app_name}.#{ENV["UNREACHABLE_DOMAIN"]}")) == 301)
        expect(Net::HTTP.get_response(URI("http://#{app_name}.#{ENV["REACHABLE_SSL_DOMAIN"]}")) == 301)
        expect(Net::HTTP.get_response(URI("http://#{app_name}.#{ENV["UNREACHABLE_SSL_DOMAIN"]}")) == 301)
        expect(Net::HTTP.get_response(URI("http://#{app_name}.#{ENV["RANDOM_DOMAIN"]}")) == 301)
        expect(Net::HTTP.get_response(URI("http://#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}")) == 301)
      end
    end

    context "with a default ssl server configured" do
      it "is possible to send https requests to all reachable apps on port 443" do
        expect(HTTParty.get("https://#{app_name}.#{ENV["REACHABLE_DOMAIN"]}:443", :verify => false).code == 200)
        expect(HTTParty.get("https://#{app_name}.#{ENV["UNREACHABLE_DOMAIN"]}:443", :verify => false).code == 401)
        expect(HTTParty.get("https://#{app_name}.#{ENV["REACHABLE_SSL_DOMAIN"]}:443", :verify => false).code == 201)
        expect(HTTParty.get("https://#{app_name}.#{ENV["UNREACHABLE_SSL_DOMAIN"]}:443", :verify => false).code == 403)
        expect(HTTParty.get("https://#{app_name}.#{ENV["RANDOM_DOMAIN"]}:443", :verify => false).code == 200)
        expect(HTTParty.get("https://#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}:443", :verify => false).code == 200)
      end

      it "is possible to send https requests to all reachable apps on port 4443" do
        expect(HTTParty.get("https://#{app_name}.#{ENV["REACHABLE_DOMAIN"]}:4443", :verify => false).code == 200)
        expect(HTTParty.get("https://#{app_name}.#{ENV["UNREACHABLE_DOMAIN"]}:4443", :verify => false).code == 401)
        expect(HTTParty.get("https://#{app_name}.#{ENV["REACHABLE_SSL_DOMAIN"]}:4443", :verify => false).code == 201)
        expect(HTTParty.get("https://#{app_name}.#{ENV["UNREACHABLE_SSL_DOMAIN"]}:4443", :verify => false).code == 403)
        expect(HTTParty.get("https://#{app_name}.#{ENV["RANDOM_DOMAIN"]}:4443", :verify => false).code == 200)
        expect(HTTParty.get("https://#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}:4443", :verify => false).code == 200)
      end
    end

    context "with a tcp forwarding on port 2222 enabled" do
      it "should be possible to create a websocket on port 2222 of the default app" do
        TCPSocket.new("#{app_name}.#{ENV["DEFAULT_APP_DOMAIN"]}", 2222).close
      end
    end
  end
end
