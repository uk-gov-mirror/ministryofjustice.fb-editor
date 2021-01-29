RSpec.describe Publisher::ServiceProvisioner do
  subject(:service_provisioner) { described_class.new(attributes) }
  let(:attributes) { {} }
  let(:service_metadata) { metadata_fixture(:version) }
  include Shoulda::Matchers::ActiveModel

  describe '#service_slug' do
    let(:attributes) { { service_id: SecureRandom.uuid } }

    before do
      expect(MetadataApiClient::Service).to receive(:latest_version)
        .with(attributes[:service_id])
        .and_return(service_metadata)
    end

    it 'returns slug using the service name' do
      expect(service_provisioner.service_slug).to eq('service-name')
    end
  end

  describe '#namespace' do
    let(:attributes) do
      { platform_environment: 'local', deployment_environment: 'dev' }
    end

    it 'returns services namespace' do
      expect(service_provisioner.namespace).to eq('formbuilder-services-local-dev')
    end
  end

  describe '#config_map_name' do
    before do
      expect(service_provisioner).to receive(:service_slug).and_return(
        'mace-windu'
      )
    end

    it 'returns the config map name prefixed by service name' do
      expect(service_provisioner.config_map_name).to eq(
        'fb-mace-windu-config-map'
      )
    end
  end

  describe '#replicas' do
    context 'when live production environment' do
      let(:attributes) do
        { platform_environment: 'live', deployment_environment: 'production' }
      end

      it 'returns 2 replicas' do
        expect(service_provisioner.replicas).to be(2)
      end
    end

    context 'when live dev environment' do
      let(:attributes) do
        { platform_environment: 'live', deployment_environment: 'dev' }
      end

      it 'returns 1 replica' do
        expect(service_provisioner.replicas).to be(1)
      end
    end

    context 'when other environments' do
      let(:attributes) do
        { platform_environment: 'test', deployment_environment: 'production' }
      end

      it 'returns 1 replica' do
        expect(service_provisioner.replicas).to be(1)
      end
    end
  end

  describe '#hostname' do
    before do
      allow(service_provisioner).to receive(:service_slug).and_return(
        'padme'
      )
    end

    context 'when live environment' do
      context 'when dev environment' do
        let(:attributes) do
          { platform_environment: 'live', deployment_environment: 'dev' }
        end

        it 'returns hostname with dev prefix' do
          expect(service_provisioner.hostname).to eq(
            'padme.dev.form.service.justice.gov.uk'
          )
        end
      end

      context 'when production environment' do
        let(:attributes) do
          { platform_environment: 'live', deployment_environment: 'production' }
        end

        it 'returns hostname' do
          expect(service_provisioner.hostname).to eq(
            'padme.form.service.justice.gov.uk'
          )
        end
      end
    end

    context 'when test environment' do
      context 'when dev environment' do
        let(:attributes) do
          { platform_environment: 'test', deployment_environment: 'dev' }
        end

        it 'returns hostname with dev prefix' do
          expect(service_provisioner.hostname).to eq(
            'padme.dev.test.form.service.justice.gov.uk'
          )
        end
      end

      context 'when production environment' do
        let(:attributes) do
          { platform_environment: 'test', deployment_environment: 'production' }
        end

        it 'returns hostname with dev prefix' do
          expect(service_provisioner.hostname).to eq(
            'padme.test.form.service.justice.gov.uk'
          )
        end
      end
    end
  end

  describe '#user_datastore_url' do
    context 'when live environment' do
      context 'when dev environment' do
        let(:attributes) do
          { platform_environment: 'live', deployment_environment: 'dev' }
        end

        it 'returns hostname with live dev prefix' do
          expect(service_provisioner.user_datastore_url).to eq(
            'http://fb-user-datastore-api-svc-live-dev.formbuilder-platform-live-dev/'
          )
        end
      end

      context 'when production environment' do
        let(:attributes) do
          { platform_environment: 'live', deployment_environment: 'production' }
        end

        it 'returns hostname' do
          expect(service_provisioner.user_datastore_url).to eq(
            'http://fb-user-datastore-api-svc-live-production.formbuilder-platform-live-production/'
          )
        end
      end
    end

    context 'when test environment' do
      context 'when dev environment' do
        let(:attributes) do
          { platform_environment: 'test', deployment_environment: 'dev' }
        end

        it 'returns hostname with test dev prefix' do
          expect(service_provisioner.user_datastore_url).to eq(
            'http://fb-user-datastore-api-svc-test-dev.formbuilder-platform-test-dev/'
          )
        end
      end

      context 'when production environment' do
        let(:attributes) do
          { platform_environment: 'test', deployment_environment: 'production' }
        end

        it 'returns hostname with dev prefix' do
          expect(service_provisioner.user_datastore_url).to eq(
            'http://fb-user-datastore-api-svc-test-production.formbuilder-platform-test-production/'
          )
        end
      end
    end
  end

  describe '#valid?' do
    context 'blank services' do
      it 'does not allow blank services' do
        should_not allow_values(nil, '').for(:service_id)
      end
    end

    context 'blank platform environment' do
      it 'does not allow' do
        should_not allow_values(nil, '').for(:platform_environment)
      end
    end

    context 'blank deployment environment' do
      it 'does not allow' do
        should_not allow_values(nil, '').for(:deployment_environment)
      end
    end

    context 'blank private public key' do
      it 'does not allow' do
        should_not allow_values([]).for(:service_configuration)
      end
    end

    context 'does not include private public key' do
      it 'does not allow' do
        should_not allow_values(
          [double(name: 'something-else')]
        ).for(:service_configuration)
      end
    end
  end
end
