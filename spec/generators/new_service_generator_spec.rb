RSpec.describe NewServiceGenerator do
  describe '#to_metadata' do
    context 'valid service metadata' do
      let(:valid) { true }
      let(:service_name) { 'Razorback' }
      let(:current_user) { double(id: '1234') }
      let(:service_metadata) do
        NewServiceGenerator.new(
          service_name: service_name,
          current_user: current_user
        ).to_metadata
      end

      it 'creates a valid service metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            service_metadata, 'service.base')
          ).to be(valid)
      end

      it 'creates start page' do
        expect(service_metadata['pages']).to be_present
        expect(service_metadata['pages'][0]).to include(
          '_type' => 'page.start',
          'url' => '/'
        )
      end
    end

    context 'invalid metadata' do
      it 'raises a schema validation error' do
        expect { MetadataPresenter::ValidateSchema.validate(
          { foo: 'bar' }, 'service.base')
        }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end
end
