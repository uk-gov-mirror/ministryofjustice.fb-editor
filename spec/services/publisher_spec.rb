RSpec.describe Publisher do
  subject(:publisher) { described_class.new(attributes) }
  let(:service_provisioner) { double }
  let(:attributes) do
    {
      publish_service: publish_service,
      service_provisioner: service_provisioner,
      adapter: fake_adapter
    }
  end
  let(:fake_adapter) do
    class FakeAdapter
      def initialize(service_provisioner); end

      def pre_publishing; end

      def publishing; end
    end
    FakeAdapter
  end

  describe '#call' do
    let(:fake_adapter_instance) { double(publishing: true) }
    let(:publish_service) do
      PublishService.create!(
        deployment_environment: 'dev',
        service_id: SecureRandom.uuid,
        status: 'queued'
      )
    end

    it 'updates status on publish service' do
      publisher.call(steps: %w[pre_publishing])
      expect(publish_service.reload.status).to eq('pre_publishing')
    end

    it 'calls publishing on adapter' do
      expect(fake_adapter).to receive(:new).with(
        service_provisioner
      ).and_return(fake_adapter_instance)
      expect(fake_adapter_instance).to receive(:publishing)
      publisher.call(steps: %w[publishing])
    end
  end
end
