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

  let(:config_dir) do
    Rails.root.join('tmp', 'publisher', service_provisioner.service_id)
  end

  before do
    allow(cloud_platform).to receive(:create_config_dir).and_return(config_dir)
    allow(service_provisioner).to receive(:service_slug).and_return('obi-wan')
  end

  describe '#pre_publishing' do
    let(:response) { :ok }

    it 'generates kubernetes configuration' do
      expect_any_instance_of(Publisher::Utils::KubernetesConfiguration).to receive(:generate)
          .with(destination: config_dir)
          .and_return(response)
      expect(cloud_platform.pre_publishing).to be(:ok)
    end
  end

  describe '#publishing' do
    before do
      expect(cloud_platform).to receive(:config_dir?).and_return(config_dir?)
    end

    context 'when config dir exists' do
      let(:config_dir?) { true }
      before do
        expect(cloud_platform).to receive(:config_files?)
          .and_return(config_files?)
      end

      context 'when config files exist' do
        let(:config_files?) { true }

        it 'calls kubecontrol' do
          expect(
            ::Publisher::Utils::KubeControl
          ).to receive(:execute).with(
            "apply -f #{config_dir}",
            namespace: 'formbuilder-services-test-dev')
          cloud_platform.publishing
        end
      end

      context 'when config files does not exist' do
        let(:config_files?) { false }

        it 'raises no config files error' do
          expect {
            cloud_platform.publishing
          }.to raise_error(
            Publisher::Adapters::CloudPlatform::ConfigFilesNotFound
          )
        end
      end
    end

    context 'when config dir does not exist' do
      let(:config_dir?) { false }

      it 'raises no config files error' do
        expect {
          cloud_platform.publishing
        }.to raise_error(
          Publisher::Adapters::CloudPlatform::ConfigFilesNotFound
        )
      end
    end
  end

  describe '#post_publishing' do
    before do
      Timecop.freeze(Time.local(2021, 2, 1, 12, 12, 12, 0))
    end

    after do
      Timecop.return
    end

    it 'patches deployment and rollout status' do
      expect(
        ::Publisher::Utils::KubeControl
      ).to receive(:execute).with(
        %{patch deployment obi-wan -p '{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"updated_at\":#{Time.now.to_i}}}}}}'},
        namespace: 'formbuilder-services-test-dev')
      expect(
        ::Publisher::Utils::KubeControl
      ).to receive(:execute).with(
        'rollout status deployment obi-wan',
        namespace: 'formbuilder-services-test-dev')
      cloud_platform.post_publishing
    end
  end
end
