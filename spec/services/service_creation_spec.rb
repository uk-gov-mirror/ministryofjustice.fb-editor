RSpec.describe ServiceCreation do
  subject(:service_creation) { described_class.new(attributes) }

  describe '#create' do
    context 'when is invalid' do
      context 'when name is blank' do
        let(:attributes) { { name: '' } }

        it 'returns false' do
          expect(service_creation.create).to be_falsey
        end
      end

      context 'when name is too short' do
        let(:attributes) { { name: 'ET' } }

        it 'returns false' do
          expect(service_creation.create).to be_falsey
        end
      end

      context 'when name is too long' do
        let(:attributes) { { name: 'E' * 129 } }

        it 'returns false' do
          expect(service_creation.create).to be_falsey
        end
      end
    end

    context 'when is valid' do
      let(:attributes) do
        { name: 'Moff Gideon', current_user: double(id: '1') }
      end
      let(:service) { double(id: '05e12a93-3978-4624-a875-e59893f2c262') }

      before do
        expect(
          MetadataApiClient::Service
        ).to receive(:create).and_return(service)
      end

      it 'returns true' do
        expect(service_creation.create).to be_truthy
      end

      it 'assigns service id' do
        service_creation.create
        expect(
          service_creation.service_id
        ).to eq('05e12a93-3978-4624-a875-e59893f2c262')
      end
    end
  end

  describe '#metadata' do
    let(:attributes) do
      { name: 'Moff Gideon', current_user: double(id: '1234') }
    end

    it 'generates the metadata for the API' do
      expect(service_creation.metadata[:metadata]).to include(
        {
          'service_name' => 'Moff Gideon',
          'created_by' => '1234'
        }
      )
    end
  end
end
