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

      context 'when user inputs name with trailing whitespace' do
        let(:current_user) { double(id: '1') }
        let(:attributes) { { name: '  Form Name  ', current_user: current_user } }

        it 'strips whitespace' do
          expect(NewServiceGenerator).to receive(:new)
            .with(name: 'Form Name', current_user: current_user)
            .and_return(double(to_metadata: 'metadata'))
          subject.metadata
        end
      end

      context 'when API returns errors' do
        let(:attributes) do
          { name: 'Moff Gideon', current_user: double(id: '1') }
        end
        let(:errors) do
          double(errors: ['Name is already been taken'], errors?: true)
        end

        before do
          expect(
            MetadataApiClient::Service
          ).to receive(:create).and_return(errors)
        end

        it 'returns false' do
          expect(service_creation.create).to be_falsey
        end

        it 'assigns error messages' do
          service_creation.create
          expect(
            service_creation.errors.full_messages
          ).to include('Name is already been taken')
        end
      end
    end

    context 'when is valid' do
      let(:attributes) do
        { name: 'Moff Gideon', current_user: double(id: '1') }
      end
      let(:service) do
        double(id: '05e12a93-3978-4624-a875-e59893f2c262', errors?: false)
      end

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

    context 'when name is invalid format' do
      [ 'something.invalid', 'with_underscore' ].each do |invalid|
        let(:attributes) { { name: invalid } }

        context "when format is #{invalid}" do
          it 'returns false' do
            expect(service_creation.create).to be_falsey
          end
        end
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
