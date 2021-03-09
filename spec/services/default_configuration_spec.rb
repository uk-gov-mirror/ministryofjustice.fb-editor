RSpec.describe DefaultConfiguration do
  subject(:default_configuration) { described_class.new(service) }
  let(:service) { double(service_id: SecureRandom.uuid) }

  describe '#create' do
    before { default_configuration.create }

    context 'generates private/public keys' do
      let(:created_configuration) do
        ServiceConfiguration.where(service_id: service.service_id)
      end
      let(:private_keys) do
        created_configuration.where(name: 'ENCODED_PRIVATE_KEY').map(&:decrypt_value)
      end
      let(:public_keys) do
        created_configuration.where(name: 'ENCODED_PUBLIC_KEY').map(&:decrypt_value)
      end
      let(:service_configuration) do
        created_configuration.map do |service_configuration|
          {
            name: service_configuration.name,
            deployment_environment: service_configuration.deployment_environment
          }
        end
      end

      it 'generates 2 keys per deployment environment' do
        expect(service_configuration).to match_array(
          [
            {
              name: 'ENCODED_PRIVATE_KEY',
              deployment_environment: 'dev'
            },
            {
              name: 'ENCODED_PUBLIC_KEY',
              deployment_environment: 'dev'
            },
            {
              name: 'ENCODED_PRIVATE_KEY',
              deployment_environment: 'production'
            },
            {
              name: 'ENCODED_PUBLIC_KEY',
              deployment_environment: 'production'
            },
          ]
        )
      end

      it 'create valid private public key' do
        expect(private_keys.size).to be(2)
        private_keys.each do |private_key|
          expect {
            key = OpenSSL::PKey::RSA.new private_key
            expect(public_keys).to include(key.public_key.to_pem)
          }.to_not raise_error
        end
      end
    end
  end
end
