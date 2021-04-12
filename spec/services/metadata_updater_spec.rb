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
    let(:attributes) do
      {
        id: 'page.start',
        service_id: service.service_id,
        latest_metadata: service_metadata
      }.merge(attributes_to_update)
    end

    context 'page attributes' do
      let(:page_url) { '/' }
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

    context 'when updating attributes and adding new components' do
      context 'when there are no components on the page' do
        let(:fixture) { metadata_fixture(:no_component_page) }
        let(:page_url) { '/confirmation' }
        let(:expected_created_component) do
          ActiveSupport::HashWithIndifferentAccess.new({
            '_id': 'confirmation_content_1',
            '_type': 'content',
            'content': '[Optional content]',
            'name': 'confirmation_content_1'
          })
        end
        let(:expected_updated_page) do
          {
            '_id' => 'page._confirmation',
            '_type' => 'page.confirmation',
            'body' => "You'll receive a confirmation email",
            'heading' => 'Complaint sent',
            'lede' => 'Updated lede',
            'url' => '/confirmation',
            'components' => [expected_created_component]
          }
        end
        let(:updated_metadata) do
          metadata = fixture.deep_dup
          metadata['pages'][-1] = metadata['pages'][-1].merge(expected_updated_page)
          metadata
        end
        let(:attributes) do
          ActiveSupport::HashWithIndifferentAccess.new({
            id: 'page._confirmation',
            service_id: service.service_id,
            latest_metadata: fixture,
            actions: { add_component: 'content' },
            lede: 'Updated lede'
          })
        end

        it 'updates the page metadata' do
          updater.update['pages'][-1]
          expect(
            updater.component_added.to_h.stringify_keys
          ).to eq(expected_created_component)
        end
      end

      context 'when there are existing components to the page' do
        context 'when add a new component type' do
          let(:new_component) do
            {
              '_id' => 'star-wars-knowledge_number_1',
              '_type' => 'number',
              'errors' => {},
              'hint' => '',
              'label' => 'Question',
              'name' => 'star-wars-knowledge_number_1',
              'validation' => { 'number' => true, 'required' => true },
              'width_class_input' => '10'
            }
          end
          let(:updated_metadata) do
            metadata = service_metadata.deep_dup
            page = metadata['pages'].find do |fixture_page|
              fixture_page['url'] == '/star-wars-knowledge'
            end

            page['components'] = page['components'].push(new_component)
            metadata
          end
          let(:attributes) do
            ActiveSupport::HashWithIndifferentAccess.new({
              service_id: service.service_id,
              latest_metadata: service_metadata,
              id: 'page.star-wars-knowledge',
              actions: { add_component: 'number' }
            })
          end

          it 'add new component' do
            updater.update['pages']
            expect(
              updater.component_added.to_h.stringify_keys
            ).to eq(new_component)
          end
        end

        context 'when add existing input components' do
          let(:new_component) do
            {
              '_id' => 'star-wars-knowledge_text_2',
              '_type' => 'text',
              'errors' => {},
              'hint' => '',
              'label' => 'Question',
              'name' => 'star-wars-knowledge_text_2',
              'validation' => { 'required' => true }
            }
          end
          let(:updated_metadata) do
            metadata = service_metadata.deep_dup
            page = metadata['pages'].find do |fixture_page|
              fixture_page['url'] == '/star-wars-knowledge'
            end

            page['components'] = page['components'].push(new_component)
            metadata
          end
          let(:attributes) do
            ActiveSupport::HashWithIndifferentAccess.new({
              service_id: service.service_id,
              latest_metadata: service_metadata,
              id: 'page.star-wars-knowledge',
              actions: { add_component: 'text' }
            })
          end

          it 'add new component' do
            updater.update['pages']
            expect(
              updater.component_added.to_h.stringify_keys
            ).to eq(new_component)
          end
        end

        context 'when add existing collection component' do
          let(:new_component) do
            {
              '_id' => 'star-wars-knowledge_radios_2',
              '_type' => 'radios',
              'errors' => {},
              'hint' => '',
              'items' => [
                {
                  '_id' => 'star-wars-knowledge_radios_2_item_1',
                  '_type' => 'radio',
                  'hint' => '',
                  'label' => 'Option',
                  'value' => 'value-1'
                },
                {
                  '_id' => 'star-wars-knowledge_radios_2_item_2',
                  '_type' => 'radio',
                  'hint' => '',
                  'label' => 'Option',
                  'value' => 'value-2'
                }
              ],
              'name' => 'star-wars-knowledge_radios_2',
              'legend' => 'Question',
              'validation' => { 'required' => true }
            }
          end
          let(:updated_metadata) do
            metadata = service_metadata.deep_dup
            page = metadata['pages'].find do |fixture_page|
              fixture_page['url'] == '/star-wars-knowledge'
            end

            page['components'] = page['components'].push(new_component)
            metadata
          end
          let(:attributes) do
            ActiveSupport::HashWithIndifferentAccess.new({
              service_id: service.service_id,
              latest_metadata: service_metadata,
              id: 'page.star-wars-knowledge',
              actions: { add_component: 'radios' }
            })
          end

          it 'add new component' do
            updater.update['pages']
            expect(
              updater.component_added.to_h.stringify_keys
            ).to eq(new_component)
          end
        end
      end
    end

    context 'when updating attributes for standalone pages' do
      let(:fixture) { metadata_fixture(:version) }
      let(:page_url) { '/privacy' }

      let(:expected_updated_page) do
        {
          '_id' => 'page.privacy',
          '_type' => 'page.standalone',
          '_uuid' => 'd658f790-0ceb-4507-b8ac-ae30ece6bc8d',
          'body' => 'Some joke about the cookie monster',
          'heading' => 'Privacy notice',
          'url' => 'privacy',
          'components' => []
        }
      end

      let(:updated_metadata) do
        metadata = fixture.deep_dup
        metadata['standalone_pages'][-1] = metadata['standalone_pages'][-1].merge(expected_updated_page)
        metadata
      end

      let(:attributes) do
        ActiveSupport::HashWithIndifferentAccess.new({
          id: 'page.privacy',
          service_id: service.service_id,
          latest_metadata: fixture
        }.merge(attributes_to_update))
      end

      let(:attributes_to_update) do
        {
          body: 'Some joke about the cookie monster'
        }.stringify_keys
      end

      it 'updates the page metadata' do
        updater.update
        expect(
          updater.update['standalone_pages'][-1]
        ).to eq(expected_updated_page)
      end
    end
  end

  describe '#destroy' do
    context 'when deleting start page' do
      let(:updated_metadata) do
        service_metadata.deep_dup
      end
      let(:attributes) do
        {
          id: 'page.start',
          service_id: service.service_id,
          latest_metadata: service_metadata
        }
      end

      it 'creates new version with start page' do
        expect(updater.destroy).to eq(updated_metadata)
      end
    end

    context 'when deleting other flow pages' do
      let(:updated_metadata) do
        metadata = service_metadata.deep_dup
        metadata['pages'].delete_at(1)
        metadata['pages'][0]['steps'].delete('page.name')
        metadata
      end
      let(:attributes) do
        {
          id: 'page.name',
          service_id: service.service_id,
          latest_metadata: service_metadata
        }
      end

      it 'creates new version with page deleted' do
        expect(updater.destroy).to eq(updated_metadata)
      end
    end

    # In future, we may not want to allow users to delete Privacy, Accessibility or Cookies standalone pages
    context 'when deleting standalone pages' do
      let(:updated_metadata) do
        metadata = service_metadata.deep_dup
        metadata['standalone_pages'].delete_at(1)
        metadata
      end
      let(:attributes) do
        {
          id: 'page.accessibility',
          service_id: service.service_id,
          latest_metadata: service_metadata
        }
      end

      it 'creates new version with page deleted' do
        expect(updater.destroy).to eq(updated_metadata)
      end
    end
  end
end
