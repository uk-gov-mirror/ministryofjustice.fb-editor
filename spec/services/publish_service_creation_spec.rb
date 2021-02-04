RSpec.describe PublishServiceCreation, type: :model do
  subject(:publish_service_creation) do
    described_class.new(attributes.merge(service_id: service_id))
  end
  let(:service_id) { service.service_id }

  describe '#save' do
    context 'when invalid' do
      context 'when require authentication' do
        let(:attributes) { { require_authentication: '1' } }

        it 'returns false' do
          expect(publish_service_creation.save).to be_falsey
        end

        it 'requires service_id' do
          should_not allow_values(nil, '').for(:service_id)
        end

        it 'requires username' do
          should_not allow_values(nil, '').for(:username)
        end

        it 'requires password' do
          should_not allow_values(nil, '').for(:password)
        end

        it 'validates min length for username' do
          should_not allow_values('a').for(:username)
        end

        it 'validates min length for password' do
          should_not allow_values('a').for(:password)
        end

        it 'validates max length for username' do
          should_not allow_values('a' * 51).for(:username)
        end

        it 'validates max length for password' do
          should_not allow_values('a' * 51).for(:password)
        end
      end

      context 'when does not require authentication' do
        let(:attributes) { { require_authentication: '0' } }

        it 'accepts blank username' do
          should allow_values(nil, '').for(:username)
        end

        it 'accepts blank password' do
          should allow_values(nil, '').for(:password)
        end
      end

      context 'when publish service is invalid' do
        let(:attributes) { { require_authentication: '0' } }

        it 'raises active record validation' do
          expect {
            publish_service_creation.save
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'when require authentication' do
      context 'when existing username and password' do
        let!(:username_config) do
          create(:service_configuration, :dev, :username, service_id: service_id)
        end
        let!(:password_config) do
          create(:service_configuration, :dev, :password, service_id: service_id)
        end
        let(:attributes) do
          {
            deployment_environment: 'dev',
            username: 'executor',
            password: 'vader-ship',
            require_authentication: '1'
          }
        end
        before { publish_service_creation.save }

        it 'returns true' do
          expect(publish_service_creation.save).to be_truthy
        end

        it 'updates username in base64' do
          expect(username_config.reload.value).to eq(Base64.strict_encode64('executor'))
        end

        it 'updates password in base64' do
          expect(password_config.reload.value).to eq(Base64.strict_encode64('vader-ship'))
        end
      end

      context 'when not existing username and password' do
        let(:attributes) do
          {
            deployment_environment: 'dev',
            username: 'executor',
            password: 'vader-ship',
            require_authentication: '1'
          }
        end
        let(:username_config) do
          ServiceConfiguration.where(
            service_id: service_id,
            deployment_environment: attributes.fetch(:deployment_environment),
            name: 'USERNAME'
          ).first
        end
        let(:password_config) do
          ServiceConfiguration.where(
            service_id: service_id,
            deployment_environment: attributes.fetch(:deployment_environment),
            name: 'PASSWORD'
          ).first
        end

        before { publish_service_creation.save }

        it 'creates username in base64' do
          expect(username_config).to be_present
          expect(username_config.value).to eq(Base64.strict_encode64('executor'))
        end

        it 'creates password in base64' do
          expect(password_config).to be_present
          expect(password_config.reload.value).to eq(Base64.strict_encode64('vader-ship'))
        end
      end
    end

    context 'when do not require authentication' do
      context 'when not existing username and password' do
      end

      context 'when existing username and password' do
        let!(:username_config) do
          create(:service_configuration, :dev, :username, service_id: service_id)
        end
        let!(:password_config) do
          create(:service_configuration, :dev, :password, service_id: service_id)
        end
        let(:attributes) do
          {
            deployment_environment: 'dev',
            username: 'something',
            password: 'other-something',
            require_authentication: '0'
          }
        end
        before { 2.times { publish_service_creation.save } }

        it 'deletes username service configuration' do
          expect(ServiceConfiguration.exists?(username_config.id)).to be_falsey
        end

        it 'deletes the password service configuration' do
          expect(ServiceConfiguration.exists?(password_config.id)).to be_falsey
        end
      end
    end
  end
end
