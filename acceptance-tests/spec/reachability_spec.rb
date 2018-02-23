require 'spec_helper'
require 'httparty'
require 'socket'
require 'pp'

include CFHelpers
include BoshHelpers
include ManifestHelpers
include CustomMatcher

describe 'ssl-gateway reachability spec for apps' do
  let(:app_name) { "checker" }

  context 'when service checker apps are pushed' do
    context "when the https redirect is enabled" do
      it "should return 301 moved permanetely for all apps on port 80" do
        expect_https_redirect(app_name, ENV["REACHABLE_DOMAIN"])
        expect_https_redirect(app_name, ENV["UNREACHABLE_DOMAIN"])
        expect_https_redirect(app_name, ENV["REACHABLE_SSL_DOMAIN"])
        expect_https_redirect(app_name, ENV["UNREACHABLE_SSL_DOMAIN"])
        expect_https_redirect(app_name, ENV["RANDOM_DOMAIN"])
        expect_https_redirect(app_name, ENV["DEFAULT_APP_DOMAIN"])
      end
    end

    context "with a default ssl server configured" do
      it "is possible to send https requests to all reachable apps on port 443" do
        expect_request(app_name, ENV["REACHABLE_DOMAIN"], 443, 200)
        expect_request(app_name, ENV["UNREACHABLE_DOMAIN"], 443, 401)
        expect_request(app_name, ENV["REACHABLE_SSL_DOMAIN"], 443, 200)
        expect_request(app_name, ENV["UNREACHABLE_SSL_DOMAIN"], 443, 403)
        expect_request(app_name, ENV["RANDOM_DOMAIN"], 443, 200)
        expect_request(app_name, ENV["DEFAULT_APP_DOMAIN"], 443, 200)
      end

      it "is possible to send https requests to all reachable apps on port 4443" do
        expect_request(app_name, ENV["REACHABLE_DOMAIN"], 4443, 200)
        expect_request(app_name, ENV["UNREACHABLE_DOMAIN"], 4443, 401)
        expect_request(app_name, ENV["REACHABLE_SSL_DOMAIN"], 4443, 200)
        expect_request(app_name, ENV["UNREACHABLE_SSL_DOMAIN"], 4443, 403)
        expect_request(app_name, ENV["RANDOM_DOMAIN"], 4443, 200)
        expect_request(app_name, ENV["DEFAULT_APP_DOMAIN"], 4443, 200)
      end
    end

    context "with a tcp forwarding on port 8833 enabled" do
      it "should be possible to create a websocket on port 8843 of the default app" do
        check_tcp_socket(app_name, ENV["DEFAULT_APP_DOMAIN"], 8843)
      end
    end
  end
end
