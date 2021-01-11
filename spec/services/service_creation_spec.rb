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
    end

    context 'when is valid' do
      let(:attributes) { { name: 'Moff Gideon', current_user: double(id: '1') } }
      let(:metadata) do
        {
          metadata: {
            _id: 'service.base',
            _type: 'service.base',
            service_name: 'Moff Gideon',
            created_by: '1',
            configuration: {
              service: {
                _id: 'config.service',
                _type: 'config.service'
              },
              meta: {
                _id: 'config.meta',
                _type: 'config.meta'
              }
            },
            pages: [
              {
                _id: 'page.start',
                _type: 'page.start',
                body: "**This is the main content section of your start page**\r\n\r\n[Edit this page](/edit) with content for your own service.\r\n\r\n## Adding more content\r\n\r\nYou can add multiple headings, links and paragraphs - all in this one content section.\r\n\r\nUse [markdown](https://www.gov.uk/guidance/how-to-publish-on-gov-uk/markdown) to format headings, bullet lists and links.",
                heading: 'This is your start page heading',
                lede: 'This is your start page first paragraph. You can only have one paragraph here.',
                steps: [],
                url: '/'
              }
            ],
            locale: 'en'
          }
        }
      end
      let(:service) { double(id: '05e12a93-3978-4624-a875-e59893f2c262') }

      before do
        expect(
          MetadataApiClient::Service
        ).to receive(:create).with(metadata).and_return(service)
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
  end
end
