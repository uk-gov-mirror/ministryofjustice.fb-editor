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

  describe '#save_user_data' do
    context 'when saving user data to the session' do
      let(:params) do
        {
          answers: { 'frodo' => 'samwise' },
          id: '123456'
        }
      end

      before do
        allow(controller).to receive(:params).and_return(params)
        controller.save_user_data
      end

      it 'saves it with the service id' do
        expect(controller.session.to_h).to eq(
          {
            "123456" => {
              "user_data" => {
                "frodo" => "samwise"
              }
            }
          }
        )
      end

      it 'retrieves user data using the service id' do
        expect(controller.load_user_data.to_h).to eq(
          { "frodo" => "samwise" }
        )
      end
    end
  end
end
