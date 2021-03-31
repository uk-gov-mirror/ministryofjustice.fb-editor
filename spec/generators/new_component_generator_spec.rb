RSpec.describe NewComponentGenerator do
  subject(:generator) do
    described_class.new(
      component_type: component_type,
      page_url: page_url,
      components: components
    )
  end
  input_components = %w[text textarea number radios checkboxes]
  non_input_components = %w[content]

  describe '#to_metadata' do
    context 'valid component metadata' do
      let(:valid) { true }

      (input_components + non_input_components).each do |component|
        context "when component '#{component}'" do
          let(:component_type) { component }
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
            expect(
              generator.to_metadata['_id']
            ).to eq("some-page_#{component}_1")
          end
        end
      end
    end

    context 'input components validation' do
      input_components.each do |component|
        context "when component '#{component}'" do
          let(:component_type) { component }
          let(:page_url) { 'some-page' }
          let(:components) { [] }

          it 'generates required validation as default' do
            expect(
              generator.to_metadata['validation']
            ).to include('required' => true)
          end
        end
      end
    end

    context 'when component has other default validation' do
      let(:component_type) { 'number' }
      let(:page_url) { 'some-page' }
      let(:components) { [] }

      it 'generates number validation as default' do
        expect(
          generator.to_metadata['validation']
        ).to include('number' => true)
      end
    end

    context 'auto generated text component id and name' do
      let(:page_url) { 'another-page' }

      context 'non collection input components' do
        %w[text textarea date number].each do |component|
          context "when #{component} component" do
            let(:component_type) { component }
            let(:components) do
              [
                {
                  '_id' => "#{page_url}_#{component}_1",
                  '_type' => component,
                  'name' => "#{page_url}_#{component}_1"
                },
                {
                  '_id' => "#{page_url}_#{component}_2",
                  '_type' => component,
                  'name' => "#{page_url}_#{component}_2"
                }
              ]
            end

            it 'should increment the newly created component id' do
              expect(generator.to_metadata['_id']).to eq("#{page_url}_#{component}_3")
            end
          end
        end
      end

      context 'collection input components' do
        let(:components) { [] }

        %w[radios checkboxes].each do |component|
          context "when #{component} component" do
            let(:component_type) { component }
            let(:expected_metadata) do
              {
                '_id' => "#{page_url}_#{component}_1",
                '_type' => component,
                'errors' => {},
                'hint' => '',
                'items' => [
                  {
                    '_id' => "#{page_url}_#{component}_1_item_1",
                    '_type' => component.singularize,
                    'hint' => '',
                    'label' => 'Option',
                    'value' => 'value-1'
                  },
                  {
                    '_id' => "#{page_url}_#{component}_1_item_2",
                    '_type' => component.singularize,
                    'hint' => '',
                    'label' => 'Option',
                    'value' => 'value-2'
                  }
                ],
                'legend' => 'Question',
                'name' => "#{page_url}_#{component}_1",
                'validation' => {
                  'required' => true
                }
              }
            end

            it 'should generate default metadata with correct item ids' do
              expect(generator.to_metadata).to eq(expected_metadata)
            end
          end
        end
      end

      context 'content components' do
        %w[content].each do |component|
          context "when #{component} component" do
            let(:component_type) { component }
            let(:components) do
              [
                {
                  '_id' => "#{page_url}_#{component}_1",
                  '_type' => component,
                  'name' => "#{page_url}_#{component}_1"
                },
                {
                  '_id' => "#{page_url}_#{component}_2",
                  '_type' => component,
                  'name' => "#{page_url}_#{component}_2"
                }
              ]
            end

            it 'should increment the newly created component id' do
              expect(generator.to_metadata['_id']).to eq("#{page_url}_#{component}_3")
            end
          end
        end
      end
    end
  end
end
