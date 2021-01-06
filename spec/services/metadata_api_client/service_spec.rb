require 'rails_helper'

RSpec.describe MetadataApiClient::Service do
  let(:metadata_api_url) { 'http://metadata-api' }
  let(:expected_url) { "#{metadata_api_url}/services/users/12345" }
  let(:expected_body) {
    {
      "services": [
        service_attributes
      ]
    }
  }
  let(:service_attributes) do
    {
      "service_name": "basset",
      "service_id": "634aa3d5-a3b3-4d0f-9078-bb754542a1d3"
    }
  end

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('METADATA_API_URL').and_return(metadata_api_url)
    stub_request(:get, expected_url)
      .to_return(status: 200, body: expected_body.to_json, headers: {})
  end

  it 'returns a list of services objects' do
    services = described_class.all(user_id: '12345')
    expect(services).to match_array([
      MetadataApiClient::Service.new(service_attributes.stringify_keys)
    ])
  end
end
