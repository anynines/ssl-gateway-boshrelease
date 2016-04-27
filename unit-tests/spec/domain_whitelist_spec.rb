require 'spec_helper'

describe 'ssl-gateway deployment with de.a9s.eu blacklisted' do
  let(:manifest) { "../manifests/domain-whitelist.yml" }

  before(:context) do
    `bosh deploy --dry-run -d ../manifests/domain-whitelist.yml -l #{ENV('IAAS_CONFIG')} -l #{ENV('EXTERNAL_SECRETS')} > /tmp/domain-whitelist.yml`
  end

  after(:context) do
    manifest = UnitTestsUtils::Manifest.fetch(:DEFAULT)
    UnitTestsUtils::Bosh.delete_deployment(manifest.name)
  end

  context 'when an internal DNS is available in the environment' do
    before(:each) do
      mongodb_client.connect
      mongodb_client.cleanup
    end

    before(:each) do
      mongodb_client.close
    end

    context 'when mongodb node is running' do
      it 'is possible to resolv the hostname for the mongodb node' do
        expect(UnitTestsUtils::InternalDNS.valid_hostnames?([hostname])).to be_truthy
      end

      it 'is possible to write data to the node' do
        mongodb_client.insert(test_value)

        expect(mongodb_client.find(test_value).count).to eq 1
      end
    end

    context 'when the node is failing' do
      it 'has persistent data after ressurrection' do
        mongodb_client.insert(test_value)

        UnitTestsUtils::Bosh.stop_instance(manifest.name, instance_name)
        UnitTestsUtils::Bosh.start_instance(manifest.name, instance_name)

        expect(mongodb_client.find(test_value).count).to eq 1
      end

      it 'is possible to write data after ressurrection' do
        UnitTestsUtils::Bosh.stop_instance(manifest.name, instance_name)
        UnitTestsUtils::Bosh.start_instance(manifest.name, instance_name)

        mongodb_client.insert(test_value)

        expect(mongodb_client.find(test_value).count).to eq 1
      end
    end
  end
end