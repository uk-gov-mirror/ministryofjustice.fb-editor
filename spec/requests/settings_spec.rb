RSpec.describe 'Settings' do
  let(:service) do
    MetadataPresenter::Service.new(service_id: SecureRandom.uuid)
  end

  describe 'PATCH /services/:id/settings/update_form_information' do
    before do
      expect_any_instance_of(ApplicationController).to receive(:service).at_least(:once).and_return(service)
      expect_any_instance_of(Settings).to receive(:update).and_return(valid)

      patch "/services/#{service.service_id}/settings/update_form_information",
            params: { service: { service_name: 'R2-D2' } }
    end

    context 'when valid' do
      let(:valid) { true }

      it 'redirects to form information index' do
        expect(response).to redirect_to(form_information_settings_path(service.service_id))
      end
    end

    context 'when invalid' do
      let(:valid) { false }

      it 'shows the previous service name' do
        expect(response.body).to include('R2-D2')
      end
    end
  end
end
