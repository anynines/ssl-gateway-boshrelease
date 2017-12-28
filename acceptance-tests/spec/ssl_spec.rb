require 'spec_helper'
require 'json'

describe 'ssl specs' do 
  let(:api) { ENV["CF_API"] }
  
  let(:cipher_scan) do
    system("../cipherscan/cipherscan -j #{api} > /tmp/cipher_scan.json")
    JSON.parse(File.read("/tmp/cipher_scan.json")
  end

  let(:allowed_ciphers) do
    'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256'.split(':')
  end

  let(:allowed_protocols) do
    ["TLSv1.2"]
  end

  context 'with a valid ssl-gateway deployment' do
    it "should have the correct default app cert bundles on all instances" do
      should = File.read(File.join(__dir__, "fixtures/wild.de.a9sapp.eu.crt.bundle"))
      expect(BoshHelpers::scp_read(0, "/var/vcap/store/nginx/ssl/wild.de.a9sapp.eu.crt.bundle")).to eq(should)
      expect(BoshHelpers::scp_read(1, "/var/vcap/store/nginx/ssl/wild.de.a9sapp.eu.crt.bundle")).to eq(should)
      expect(BoshHelpers::scp_read(2, "/var/vcap/store/nginx/ssl/wild.de.a9sapp.eu.crt.bundle")).to eq(should)
    end

    it "should have the correct ssltest cert bundles on all instances" do
      should = File.read(File.join(__dir__, "fixtures/wild.checker.ssltest.com.crt.bundle"))
      expect(BoshHelpers::scp_read(0, "/var/vcap/store/nginx/ssl/wild.checker.ssltest.com.crt.bundle")).to eq(should)
      expect(BoshHelpers::scp_read(1, "/var/vcap/store/nginx/ssl/wild.checker.ssltest.com.crt.bundle")).to eq(should)
      expect(BoshHelpers::scp_read(2, "/var/vcap/store/nginx/ssl/wild.checker.ssltest.com.crt.bundle")).to eq(should)
    end

    it "should have the correct ssltest cert bundles on all instances" do
      should = File.read(File.join(__dir__, "fixtures/wild.checker.ssltest2.com.crt.bundle"))
      expect(BoshHelpers::scp_read(0, "/var/vcap/store/nginx/ssl/wild.checker.ssltest2.com.crt.bundle")).to eq(should)
      expect(BoshHelpers::scp_read(1, "/var/vcap/store/nginx/ssl/wild.checker.ssltest2.com.crt.bundle")).to eq(should)
      expect(BoshHelpers::scp_read(2, "/var/vcap/store/nginx/ssl/wild.checker.ssltest2.com.crt.bundle")).to eq(should)
    end

    it "should have the correct ciphers" do
      cipher_scan["cipher_suite"].each do |cipher|
        expect(allowed_ciphers).to include(cipher["cipher"])
      end
    end

    it "should use the correct protocol" do
      cipher_scan["cipher_suite"].each do |cipher|
        expect(allowed_protocols).to include(cipher["protocol"])
      end
    end
  end
end