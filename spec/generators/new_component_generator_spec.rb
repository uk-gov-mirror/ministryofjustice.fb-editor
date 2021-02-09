RSpec.describe NewComponentGenerator do
  subject(:generator) do
    described_class.new(component_type: component_type, page_url: page_url, components: components)
  end

  describe '#to_metadata' do
    context 'valid component metadata' do

      let(:valid) { true }

      context 'text component' do
        let(:component_type) { 'text' }
        let(:page_url) { 'some-page' }
        let(:components) { [] }

        it 'creates valid text field component metadata' do
          expect(
            MetadataPresenter::ValidateSchema.validate(
              generator.to_metadata, "component.#{component_type}"
            )
          ).to be(valid)
        end

        it 'generates the component id' do
          expect(generator.to_metadata['_id']).to eq('some-page_text_1')
        end
      end
    end

    context 'auto generated text component id and name' do
      let(:component_type) { 'text' }
      let(:page_url) { 'another-page' }
      let(:components) do
        [
          {
            "_id" => "another-page_text_1",
            "_type" => "text",
            "name" => "another-page_text_1"
          },
          {
            "_id" => "another-page_text_2",
            "_type" => "text",
            "name" => "another-page_text_2"
          }
        ]
      end

      it 'should increment the newly created component id' do
        expect(generator.to_metadata['_id']).to eq('another-page_text_3')
      end
    end
  end
end
