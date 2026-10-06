require 'rails_helper'

RSpec.describe 'Admin events page', type: :request do
  let(:current_user) { create(:user) }

  before do
    allow_any_instance_of(Admin::ApplicationController).to receive(:require_user!).and_return(true)
    allow_any_instance_of(Admin::ApplicationController).to receive(:current_user).and_return(current_user)
    allow_any_instance_of(Admin::ApplicationController).to receive(:moj_forms_dev?).and_return(true)
  end

  it 'tells the admin when nothing has been recorded yet' do
    get admin_events_path

    expect(response.status).to eq(200)
    expect(response.body).to include('No admin actions have been recorded yet')
  end

  context 'with more events than fit on one page' do
    before do
      60.times do |i|
        AdminEvent.create!(
          action: "Action number #{i}",
          created_at: i.minutes.ago
        )
      end
    end

    it 'shows the most recent 50 on the first page and paginates the rest' do
      get admin_events_path

      expect(response.body).to include('Action number 0')
      expect(response.body).to include('Action number 49')
      expect(response.body).not_to include('Action number 59')
      expect(response.body).to include('page=2')
    end

    it 'reaches the oldest events on a later page' do
      get admin_events_path(page: 2)

      expect(response.body).to include('Action number 59')
      expect(response.body).not_to include('Action number 0')
    end
  end

  context 'when an event belongs to a service' do
    let(:service_id) { SecureRandom.uuid }

    before do
      AdminEvent.create!(action: 'Maintenance mode enabled', service_id:)
    end

    it 'shows the current service name looked up from the metadata API' do
      allow(MetadataApiClient::Service).to receive(:latest_version)
        .with(service_id)
        .and_return('service_name' => 'Apply for a licence')

      get admin_events_path

      expect(response.body).to include('Apply for a licence')
    end

    it 'falls back to the service id when the service can no longer be found' do
      allow(MetadataApiClient::Service).to receive(:latest_version)
        .with(service_id)
        .and_raise(Faraday::ResourceNotFound.new('not found'))

      get admin_events_path

      expect(response.status).to eq(200)
      expect(response.body).to include(service_id)
    end
  end
end
