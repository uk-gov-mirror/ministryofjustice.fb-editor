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
            service_metadata, 'service.base'
          )
        ).to be(valid)
      end

      it 'creates start page' do
        expect(service_metadata['pages']).to be_present
        expect(service_metadata['pages'][0]).to include(
          '_type' => 'page.start',
          'url' => '/'
        )
      end

      it 'creates the default footer pages' do
        expect(service_metadata['standalone_pages'].count).to eq(3)

        urls = service_metadata['standalone_pages'].map { |page| page['url'] }
        I18n.t('footer').each do |page|
          expect(urls).to include(page[:url])
        end
      end

      it 'creates valid pages' do
        all_pages = service_metadata['pages'] + service_metadata['standalone_pages']
        all_pages.each do |page|
          expect(
            MetadataPresenter::ValidateSchema.validate(page, page['_type'])
          ).to be(valid)
        end
      end
    end

    context 'invalid metadata' do
      it 'raises a schema validation error' do
        expect {
          MetadataPresenter::ValidateSchema.validate(
            { foo: 'bar' }, 'service.base'
          )
        }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end
end
