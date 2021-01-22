RSpec.describe PageCreation, type: :model do
  subject(:page_creation) do
    described_class.new(attributes)
  end
  let(:attributes) { { latest_metadata: metadata_fixture(:version) } }

  describe '#create' do
    let(:attributes) do
      {
        page_type: 'singlequestion',
        component_type: 'text',
        page_url: 'admiral-ackbar',
        service_id: 'it-is-a-trap',
        latest_metadata: metadata_fixture(:version)
      }
    end

    context 'when is valid' do
      let(:version) { double(errors?: false) }
      before do
        expect(
          MetadataApiClient::Version
        ).to receive(:create).and_return(version)
      end

      it 'returns true' do
        expect(page_creation.create).to be_truthy
      end
    end

    context 'when is invalid' do
      context 'when attributes invalid' do
        let(:attributes) do
          { page_url: '/foo/bar/baz', latest_metadata: metadata_fixture(:version) }
        end

        it 'returns false' do
          expect(page_creation.create).to be_falsey
        end
      end

      context 'when metadata api returns invalid' do
        let(:error_messages) { double(errors?: true, errors: ['An awful error']) }
        before do
          expect(
            MetadataApiClient::Version
          ).to receive(:create).and_return(error_messages)
        end

        it 'returns false' do
          expect(page_creation.create).to be_falsey
        end
      end
    end
  end

  describe 'validations' do
    before { page_creation.valid? }

    context 'page url' do
      context 'when is valid' do
        it 'have no errors' do
          should allow_values(
            'email-info', 'fullname', 'r2d2'
          ).for(:page_url)
        end
      end

      context 'when is invalid' do
        context 'when format is invalid' do
          it 'have errors' do
            should_not allow_values('email.address').for(:page_url)
          end
        end

        context 'when is blank' do
          it 'have errors' do
            should_not allow_values('').for(:page_url)
          end
        end

        context 'when url already exists on the same metadata' do
          it 'have errors' do
            should_not allow_values(
              '/',
              'name',
              '/name',
              'email-address',
              '/email-address',
              'parent-name',
              'confirmation',
              'check-answers'
            ).for(:page_url)
          end
        end
      end
    end

    context 'page type' do
      context 'when is valid' do
        it 'have no errors' do
          should allow_values(
            'singlequestion', 'checkanswers', 'confirmation'
          ).for(:page_type)
        end
      end

      context 'when is blank' do
        it 'have errors' do
          should_not allow_values('').for(:page_type)
        end
      end

      context 'when is invalid' do
        context 'when not supported page type (not in default metadata)' do
          it 'have no errors' do
            should_not allow_values(
              'this-type-of-page-will-never-exist', 'metadatron3000'
            ).for(:page_type)
          end
        end
      end
    end

    context 'component type' do
      context 'when is valid' do
        it 'have no errors' do
          should allow_values('text').for(:component_type)
        end
      end

      context 'when is blank' do
        it 'have errors' do
          should_not allow_values('').for(:component_type)
        end
      end

      context 'when is invalid' do
        context 'when not supported type (not in default metadata)' do
          it 'have errors' do
            should_not allow_values(
              'this-type-of-component-will-never-exist', 'metadatron3000'
            ).for(:component_type)
          end
        end
      end
    end
  end
end
