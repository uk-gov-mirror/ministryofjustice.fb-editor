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

  describe '#user_name' do
    context 'with a current user' do
      context 'two names' do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(
            double(name: 'Peggy Carter')
          )
        end

        it 'should show the correctly formatted user name' do
          expect(controller.user_name).to eq('P. Carter')
        end
      end

      context 'more than two names' do
        before do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(
            double(name: 'Sponge Bob Square Pants')
          )
        end

        it 'should show the correctly formatted user name' do
          expect(controller.user_name).to eq('S. Pants')
        end
      end
    end
  end
end
