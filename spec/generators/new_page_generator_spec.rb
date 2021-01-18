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
    context 'valid service metadata' do
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
      end
    end
  end
end
