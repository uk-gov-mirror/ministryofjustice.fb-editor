RSpec.describe MetadataApiClient::Service do
  let(:metadata_api_url) { 'http://metadata-api' }
  let(:expected_body) do
    {
      "services": [
        service_attributes
      ]
    }
  end
  let(:service_attributes) do
    {
      "service_name": 'basset',
      "service_id": '634aa3d5-a3b3-4d0f-9078-bb754542a1d3'
    }
  end

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('METADATA_API_URL').and_return(metadata_api_url)
  end

  describe '.all' do
    let(:expected_url) { "#{metadata_api_url}/services/users/12345" }

    before do
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

  describe '.create' do
    let(:expected_url) { "#{metadata_api_url}/services" }
    let(:expected_body) do
      { 'service_name' => 'Grogu', 'service_id' => 'some-id' }
    end

    context 'when created' do
      before do
        stub_request(:post, expected_url)
          .to_return(status: 201, body: expected_body.to_json, headers: {})
      end

      it 'assigns a service' do
        expect(described_class.create({})).to eq(
          described_class.new(expected_body)
        )
      end

      it 'returns no errors' do
        expect(described_class.create({}).errors?).to be_falsey
      end
    end

    context 'when unprocessable entity' do
      let(:expected_body) do
        { 'message' => ['Name has already been taken'] }
      end

      before do
        stub_request(:post, expected_url)
          .to_return(status: 422, body: expected_body.to_json, headers: {})
      end

      it 'assigns an error message' do
        expect(described_class.create({})).to eq(
          MetadataApiClient::ErrorMessages.new(['Name has already been taken'])
        )
      end

      it 'returns errors' do
        expect(described_class.create({}).errors?).to be_truthy
      end
    end
  end

  describe '.latest_version' do
    let(:expected_url) { "#{metadata_api_url}/services/12345/versions/latest" }
    let(:expected_body) do
      JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'service.json')))
    end

    before do
      stub_request(:get, expected_url)
        .to_return(status: 200, body: expected_body.to_json, headers: {})
    end

    it 'returns latest metadata' do
      expect(described_class.latest_version('12345')).to eq(expected_body)
    end
  end
end
