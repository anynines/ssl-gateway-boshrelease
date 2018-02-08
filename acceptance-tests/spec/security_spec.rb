require 'spec_helper'
require 'json'
require 'pp'
require 'httparty'

describe 'ssl specs' do 
  let(:app_name) { "checker" }
  let(:api) { ENV["CF_API"] }
  let(:cipherscan) { File.join(__dir__, "../cipherscan/cipherscan") }
  
  let(:cipher_scan) do
    system("#{cipherscan} -j #{api} > /tmp/cipher_scan.json")
    JSON.parse(File.read("/tmp/cipher_scan.json"))
  end

  let(:allowed_ciphers) do
    'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256'.split(':')
  end

  let(:allowed_protocols) do
    ["TLSv1.2"]
  end

  context 'with a valid ssl-gateway deployment' do
    it "should have the correct default app cert bundles on all instances" do
      check_ssl_cert_bundle([0, 1, 2], "fixtures/wild.de.a9sapp.eu.crt.bundle", "/var/vcap/store/nginx/ssl/wild.de.a9sapp.eu.crt.bundle")
    end

    it "should have the correct ssltest cert bundles on all instances" do
      check_ssl_cert_bundle([0, 1, 2], "fixtures/wild.checker.ssltest.com.crt.bundle", "/var/vcap/store/nginx/ssl/wild.checker.ssltest.com.crt.bundle")
    end

    it "should have the correct ssltest2 cert bundles on all instances" do
      check_ssl_cert_bundle([0, 1, 2], "fixtures/wild.de.checker.ssltest2.com.crt.bundle", "/var/vcap/store/nginx/ssl/wild.ssltest2.com.crt.bundle")
    end

    it "should have the correct ciphers" do
      cipher_scan["ciphersuite"].each do |cipher|
        expect(allowed_ciphers).to include(cipher["cipher"])
      end
    end

    it "should support the correct TLS protocols" do
      cipher_scan["ciphersuite"].each do |cipher|
        cipher["protocols"].each { |protocol| expect(allowed_protocols.include?(protocol)) }
      end
    end

    it "should not show the nginx version in header" do
      expect(HTTParty.get("https://#{app_name}.#{ENV["REACHABLE_DOMAIN"]}:443", :verify => false).headers["server"] == "nginx")
    end
  end
end
