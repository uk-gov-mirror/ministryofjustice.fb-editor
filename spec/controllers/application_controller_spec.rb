RSpec.describe ApplicationController do
  describe '#editable?' do
    before do
      allow(
        controller.request
      ).to receive(:script_name).and_return(script_name)
    end

    context 'when editing a page' do
      let(:script_name) { 'services/1/pages/2/edit' }

      it 'returns true' do
        expect(controller).to be_editable
      end
    end

    context 'when previewing a page' do
      let(:script_name) { 'services/1/preview' }

      it 'returns true' do
        expect(controller).to_not be_editable
      end
    end
  end
end
