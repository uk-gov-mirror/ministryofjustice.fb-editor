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
            namespace: 'formbuilder-services-test-dev'
          )
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
    it 'restart deployment and rollout status' do
      expect(
        ::Publisher::Utils::KubeControl
      ).to receive(:execute).with(
        'rollout restart deployment obi-wan',
        namespace: 'formbuilder-services-test-dev'
      )
      expect(
        ::Publisher::Utils::KubeControl
      ).to receive(:execute).with(
        'rollout status deployment obi-wan',
        namespace: 'formbuilder-services-test-dev'
      )
      cloud_platform.post_publishing
    end
  end

  describe '#completed' do
    let(:service_id) { '0da69306-cafd-4d32-bbee-fff98cac74ce' }
    let(:service_provisioner) do
      ::Publisher::ServiceProvisioner.new(
        service_id: service_id,
        platform_environment: platform_environment,
        deployment_environment: deployment_environment
      )
    end

    before do
      allow(service_provisioner).to receive(:service_name).and_return('sam-or-frodo')
      allow(service_provisioner).to receive(:hostname).and_return('sam-or-frodo.service.justice.gov.uk')
    end

    context 'publishing to live-production' do
      let(:platform_environment) { 'live' }
      let(:deployment_environment) { 'production' }

      context 'when first published' do
        let!(:publish_service_production) do
          create(:publish_service, :completed, :production, service_id: service_id)
        end

        context 'when there is a published for development' do
          let!(:publish_service) do
            create(:publish_service, :completed, :dev, service_id: service_id)
          end

          it 'sends a notification to the slack channel' do
            expect(NotificationService).to receive(:notify).with("sam-or-frodo has been published to formbuilder-services-live-production.\nsam-or-frodo.service.justice.gov.uk")
            cloud_platform.completed
          end
        end

        context 'when publish directly to live production' do
          it 'sends a notification to the slack channel' do
            expect(NotificationService).to receive(:notify).with("sam-or-frodo has been published to formbuilder-services-live-production.\nsam-or-frodo.service.justice.gov.uk")
            cloud_platform.completed
          end
        end
      end

      context 'when not on first publish' do
        let!(:publish_service) do
          create(:publish_service, :completed, :production, service_id: service_id)
        end
        let!(:publish_service_two) do
          create(:publish_service, :completed, :production, service_id: service_id)
        end

        it 'does not send a notification to the slack channel' do
          expect(NotificationService).not_to receive(:notify)
          cloud_platform.completed
        end
      end
    end

    context 'when not live production' do
      let(:platform_environment) { 'live' }
      let(:deployment_environment) { 'dev' }

      it 'does not send a notification to the slack channel' do
        expect(NotificationService).not_to receive(:notify)
        cloud_platform.completed
      end
    end
  end
end
