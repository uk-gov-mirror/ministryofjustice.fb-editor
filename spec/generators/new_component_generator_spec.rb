RSpec.describe NewComponentGenerator do
  subject(:generator) do
    described_class.new(component_type: component_type, page_id: page_id)
  end

  describe '#to_metadata' do
    context 'valid component metadata' do
      let(:valid) { true }

      context 'text component' do
        let(:component_type) { 'text' }
        let(:page_id) { 'some-page' }

        it 'creates valid text field component metadata' do
          expect(
            MetadataPresenter::ValidateSchema.validate(
              generator.to_metadata, component_type
            )
          ).to be(valid)
        end

        it 'generates the component id' do
          expect(generator.to_metadata['_id']).to_not be_blank
        end
      end
    end
  end
end
