require 'rails_helper'

RSpec.describe ServiceConfiguration, type: :model do
  describe '#valid?' do
    context 'service_id' do
      it 'do not allow blank' do
        should_not allow_values('').for(:service_id)
      end
    end

    context 'name' do
      it 'do not allow blank' do
        should_not allow_values('').for(:name)
      end
    end

    context 'value' do
      it 'do not allow blank' do
        should_not allow_values('').for(:value)
      end
    end

    context 'deployment environment' do
      it 'allow dev and production' do
        should allow_values('dev', 'production').for(:deployment_environment)
      end

      it 'do not allow enything else' do
        should_not allow_values(
          nil, '', 'something-else', 'staging', 'live', 'test'
        ).for(:deployment_environment)
      end
    end
  end

  describe '#secrets?' do
    context 'when is a secret' do
      let(:service_configuration) do
        build(
          :service_configuration,
          name: 'ENCODED_PRIVATE_KEY'
        )
      end

      it 'returns true' do
        expect(service_configuration).to be_secrets
      end
    end

    context 'when is a config map' do
      let(:service_configuration) do
        build(
          :service_configuration,
          name: 'ENCODED_PUBLIC_KEY'
        )
      end

      it 'returns false' do
        expect(service_configuration).to_not be_secrets
      end
    end
  end

  context 'encrypting and decrypting values' do
    let(:service_configuration) do
      create(:service_configuration, :dev, :username, value: 'r2d2')
    end

    describe '#before_save' do
      context 'encrypting value' do
        it 'saves a encrypted value' do
          expect(service_configuration.value).not_to eq('r2d2')
        end
      end
    end

    describe '#decrypt_value' do
      context 'decrypting value' do
        it 'decrypts a value from the db' do
          expect(service_configuration.decrypt_value).to eq('r2d2')
        end
      end
    end

    describe '#encode64' do
      context 'base64 encoded value' do
        it 'base64 encodes the value' do
          expect(service_configuration.encode64).to eq(Base64.strict_encode64('r2d2'))
        end
      end
    end
  end
end
