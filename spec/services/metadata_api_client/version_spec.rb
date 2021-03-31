RSpec.describe MetadataApiClient::Version do
  let(:metadata_api_url) { 'http://metadata-api' }
  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('METADATA_API_URL').and_return(metadata_api_url)
  end

  describe '.create' do
    let(:service_id) { SecureRandom.uuid }
    let(:expected_url) { "#{metadata_api_url}/services/#{service_id}/versions" }

    context 'when is created' do
      let(:expected_body) do
        { service_name: 'Asohka Tano', service_id: service_id }
      end

      before do
        stub_request(:post, expected_url)
          .to_return(status: 201, body: expected_body.to_json, headers: {})
      end

      it 'returns a version' do
        expect(
          described_class.create(
            service_id: service_id, payload: expected_body
          )
        ).to eq(described_class.new(expected_body.stringify_keys))
      end
    end

    context 'when is unprocessable entity' do
      let(:expected_body) do
        { 'message': ['Name has already been taken'] }
      end

      before do
        stub_request(:post, expected_url)
          .to_return(status: 422, body: expected_body.to_json, headers: {})
      end

      it 'assigns an error message' do
        expect(
          described_class.create(service_id: service_id, payload: {})
        ).to eq(
          MetadataApiClient::ErrorMessages.new(['Name has already been taken'])
        )
      end

      it 'returns errors' do
        expect(
          described_class.create(service_id: service_id, payload: {}).errors?
        ).to be_truthy
      end
    end
  end
end
