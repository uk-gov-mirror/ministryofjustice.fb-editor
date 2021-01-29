RSpec.describe Publisher::Adapters::CloudPlatform do
  subject(:cloud_platform) do
    described_class.new(service_provisioner)
  end
  let(:service_provisioner) do
    ::Publisher::ServiceProvisioner.new(
      service_id: '0da69306-cafd-4d32-bbee-fff98cac74ce',
      platform_environment: 'test',
      deployment_environment: 'dev'
    )
  end

  describe '#pre_publishing' do
    let(:response) { :ok }
    let(:config_dir) { Rails.root.join('tmp', 'publisher') }

    before do
      allow(cloud_platform).to receive(:config_dir).and_return(config_dir)
    end

    it 'generates kubernetes configuration' do
      expect_any_instance_of(Publisher::Utils::KubernetesConfiguration).to receive(:generate)
          .with(destination: config_dir)
          .and_return(response)
      expect(cloud_platform.pre_publishing).to be(:ok)
    end
  end
end
