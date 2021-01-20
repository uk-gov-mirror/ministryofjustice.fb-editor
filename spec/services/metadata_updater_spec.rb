RSpec.describe MetadataUpdater do
  subject(:updater) { MetadataUpdater.new(attributes) }
  let(:service_id) { service.service_id }
  let(:updated_metadata) do
    metadata = service_metadata.deep_dup
    metadata['pages'][0] = metadata['pages'][0].merge(attributes_to_update)
    metadata
  end
  let(:version) { double(errors?: false, errors: [], metadata: updated_metadata) }

  before do
    expect(
      MetadataApiClient::Version
    ).to receive(:create).with(
      service_id: service_id,
      payload: updated_metadata
    ).and_return(version)
  end

  describe '#update' do
    let(:valid) { true }

    context 'page attributes' do
      let(:page_url) { '/' }
      let(:attributes) do
        {
          id: 'page.start',
          service_id: service.service_id,
          latest_metadata: service_metadata,
        }.merge(attributes_to_update)
      end
      let(:attributes_to_update) do
        {
          section_heading: 'Some important section heading',
          heading: 'Some super important heading',
          lede: 'This is a lede',
          body: 'And what of the Rebellion?',
          before_you_start: "Don't try to frighten us with your sorcerer's ways, Lord Vader."
        }.stringify_keys
      end

      it 'updates the page metadata' do
        updated_page = updater.update['pages'][0]
        expect(updated_page).to include(attributes_to_update)
      end

      it 'creates valid page metadata' do
        updated_page = updater.update['pages'][0]
        expect(
          MetadataPresenter::ValidateSchema.validate(
            updated_page, 'page.start'
          )
        ).to be(valid)
      end

      it 'creates valid service metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            updater.update, 'service.base'
          )
        ).to be(valid)
      end
    end
  end
end
