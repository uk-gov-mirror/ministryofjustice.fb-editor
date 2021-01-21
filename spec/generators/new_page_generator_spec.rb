RSpec.describe NewPageGenerator do
  subject(:generator) do
    described_class.new(
      page_type: page_type,
      page_url: page_url,
      component_type: component_type,
      latest_metadata: latest_metadata
    )
  end

  describe '#to_metadata' do
    let(:valid) { true }
    let(:page_type) { 'singlequestion' }
    let(:page_url) { 'home-one' }
    let(:component_type) { 'text' }

    context 'when only start page exists' do
      let(:latest_metadata) { metadata_fixture(:service) }

      it 'creates a valid page metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            generator.page_metadata, "page.#{page_type}"
          )
        ).to be(valid)
      end

      it 'create valid update service metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            generator.to_metadata, 'service.base'
          )
        ).to be(valid)
      end

      it 'generates page url' do
        expect(generator.to_metadata['pages']).to_not be_blank
        expect(generator.to_metadata['pages'].last).to include(
          'url' => page_url
        )
      end

      it 'generates the new component metadata' do
        generated_page = generator.to_metadata['pages'].last
        expect(generated_page['components']).to_not be_blank
        expect(generated_page['components'].last).to include(
          '_type' => component_type
        )
      end

      it 'adds the new page to the steps' do
        expect(generator.to_metadata['pages'][0]['steps']).to include("page.#{page_url}")
      end
    end

    context 'when existing pages exist' do
      let(:latest_metadata) { metadata_fixture(:version) }

      it 'creates a valid page metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            generator.page_metadata, "page.#{page_type}"
          )
        ).to be(valid)
      end

      it 'generates page attributes' do
        expect(generator.to_metadata['pages']).to_not be_blank
        expect(generator.to_metadata['pages'].last).to include(
          'url' => page_url,
          '_id' => 'page.home-one',
          '_type' => 'page.singlequestion',
          'heading' => 'Question',
          'lede' => 'This is the lede',
          'body' => 'Body section',
          'components' => [
            {
              '_id'    => "#{page_url}_#{component_type}_1",
              '_type'  => 'text',
              'errors' => {},
              'hint'   => 'Component hint',
              'label'  => 'Component label',
              'name'   => "#{page_url}_#{component_type}_1"
            }
          ]
        )
      end
    end
  end
end
