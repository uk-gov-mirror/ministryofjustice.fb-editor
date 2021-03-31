RSpec.describe Settings do
  subject(:settings) do
    described_class.new(
      attributes.merge(
        service_id: '123456',
        latest_metadata: latest_metadata
      )
    )
  end
  let(:latest_metadata) do
    { service_name: 'Grogu' }
  end
  let(:current_user) do
    double(id: SecureRandom.uuid)
  end

  describe '#update' do
    context 'when valid' do
      let(:attributes) do
        { service_name: 'Moff Gideon', current_user: current_user }
      end
      let(:service) do
        double(id: '05e12a93-3978-4624-a875-e59893f2c262', errors?: false)
      end

      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
        allow_any_instance_of(PermissionsController).to receive(:require_user!).and_return(true)

        expect(
          MetadataApiClient::Version
        ).to receive(:create).with(
          service_id: '123456',
          payload: { service_name: 'Moff Gideon', created_by: current_user.id }
        ).and_return(service)
      end

      it 'returns true' do
        expect(settings.update).to be_truthy
      end
    end

    context 'when invalid' do
      context 'when name is blank' do
        let(:attributes) { { service_name: '' } }

        it 'returns false' do
          expect(settings.update).to be_falsey
        end
      end

      context 'when name is too short' do
        let(:attributes) { { service_name: 'ET' } }

        it 'returns false' do
          expect(settings.update).to be_falsey
        end
      end

      context 'when name is too long' do
        let(:attributes) { { service_name: 'E' * 129 } }

        it 'returns false' do
          expect(settings.update).to be_falsey
        end
      end

      context 'when API returns errors' do
        let(:attributes) do
          { service_name: 'Moff Gideon', current_user: double(id: '1') }
        end
        let(:errors) do
          double(errors: ['Name is already been taken'], errors?: true)
        end

        before do
          expect(
            MetadataApiClient::Version
          ).to receive(:create).and_return(errors)
        end

        it 'returns false' do
          expect(settings.update).to be_falsey
        end

        it 'assigns error messages' do
          settings.update
          expect(
            settings.errors.full_messages.first
          ).to include('is already used by another form. Please modify it.')
        end
      end
    end
  end
end
