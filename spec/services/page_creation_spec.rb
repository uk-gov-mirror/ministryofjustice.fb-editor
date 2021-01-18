RSpec.describe PageCreation do
  subject(:page_creation) do
    described_class.new(attributes)
  end

  describe 'validations' do
    context 'page url' do
      context 'when is valid' do
      end

      context 'when is invalid' do
        context 'when format is invalid' do
        end

        context 'when is blank' do
        end

        context 'when already exists on the same metadata' do
        end
      end
    end

    context 'page type' do
      context 'when is valid' do
      end

      context 'when is invalid' do
        context 'when not supported page type (not in default metadata)' do
        end
      end
    end

    context 'component type' do
      context 'when is valid' do
      end

      context 'when is invalid' do
        context 'when not supported type (not in default metadata)' do
        end
      end
    end
  end
end
