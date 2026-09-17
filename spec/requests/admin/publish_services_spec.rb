RSpec.describe 'Admin publish services index', type: :request do
  let(:current_user) { double(id: SecureRandom.uuid, email: 'ellen.ripley@nostromo.eg') }
  let(:service_id) { SecureRandom.uuid }

  before do
    allow_any_instance_of(Admin::ApplicationController).to receive(:require_user!).and_return(true)
    allow_any_instance_of(
      Admin::ApplicationController
    ).to receive(:current_user).and_return(current_user)
    allow_any_instance_of(
      Admin::ApplicationController
    ).to receive(:moj_forms_dev?).and_return(true)

    allow(MetadataApiClient::Service).to receive(:latest_version).and_return(
      { 'service_name' => 'My Live Form' }
    )
  end

  context 'when there are publish records across environments' do
    let(:user) { create(:user, name: 'Ada Lovelace') }
    let!(:old_production) do
      create(:publish_service, :production, :completed,
             service_id:, user:, created_at: 2.days.ago)
    end
    let!(:latest_production) do
      create(:publish_service, :production, :completed,
             service_id:, user:, created_at: 1.hour.ago)
    end
    let!(:dev_publish) do
      create(:publish_service, :dev, :completed, user:)
    end

    it 'defaults to the production (Live) environment' do
      get '/admin/publish_services'

      expect(response.status).to eq(200)
      expect(response.body).to include('My Live Form')
      expect(response.body).to include('Live')
    end

    it 'de-duplicates to one row per service (latest state)' do
      get '/admin/publish_services'

      expect(response.body.scan('My Live Form').size).to eq(1)
    end

    it 'excludes records from the other environment by default' do
      get '/admin/publish_services'

      expect(response.body).not_to include(dev_publish.service_id)
    end

    it 'links the form name to the admin service page' do
      get '/admin/publish_services'

      expect(response.body).to include(admin_service_path(service_id))
    end

    it 'shows the publishing user name linked to the admin user page' do
      get '/admin/publish_services'

      expect(response.body).to include('Ada Lovelace')
      expect(response.body).to include(admin_user_path(user))
    end

    it 'toggles to the dev (Test) environment' do
      get '/admin/publish_services', params: { deployment_environment: 'dev' }

      expect(response.status).to eq(200)
      expect(response.body).to include('Test')
    end
  end

  context 'when the latest record is unpublished' do
    let(:user) { create(:user) }
    let!(:publish) do
      create(:publish_service, :production, :unpublished, service_id:, user:)
    end

    it 'shows an Unpublished status' do
      get '/admin/publish_services'

      expect(response.body).to include('Unpublished')
    end
  end

  context 'when the service is in maintenance mode' do
    let(:user) { create(:user) }
    let!(:publish) do
      create(:publish_service, :production, :completed, service_id:, user:)
    end
    let!(:maintenance) do
      create(:service_configuration, :production, :maintenance_mode, service_id:)
    end

    it 'shows a Maintenance mode status' do
      get '/admin/publish_services'

      expect(response.body).to include('Maintenance mode')
    end
  end

  context 'when there are no publish records' do
    it 'renders an empty state' do
      get '/admin/publish_services'

      expect(response.status).to eq(200)
      expect(response.body).to include('No services published to Live')
    end
  end
end
