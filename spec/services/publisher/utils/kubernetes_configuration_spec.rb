RSpec.describe Publisher::Utils::KubernetesConfiguration do
  subject(:kubernetes_configuration) do
    described_class.new(service_provisioner)
  end
  let(:service_provisioner) do
    ::Publisher::ServiceProvisioner.new(
      service_id: '0da69306-cafd-4d32-bbee-fff98cac74ce',
      platform_environment: 'test',
      deployment_environment: 'dev',
      service_configuration: [
        build(:service_configuration, name: 'ENCODED_PRIVATE_KEY', value: private_key),
        build(:service_configuration, name: 'ENCODED_PUBLIC_KEY', value: public_key),
        build(:service_configuration, name: 'BASIC_AUTH_USER', value: basic_auth_user),
        build(:service_configuration, name: 'BASIC_AUTH_PASS', value: basic_auth_pass),
      ]
    )
  end
  let(:private_key) do
    EncryptionService.new.encrypt(
      File.read(Rails.root.join('spec', 'fixtures', 'private_key'))
    )
  end
  let(:public_key) do
    EncryptionService.new.encrypt(
      File.read(Rails.root.join('spec', 'fixtures', 'public_key'))
    )
  end
  let(:basic_auth_user) do
    EncryptionService.new.encrypt('droid')
  end
  let(:basic_auth_pass) do
    EncryptionService.new.encrypt('r2d2')
  end

  before do
    allow(service_provisioner).to receive(:service).and_return(
      MetadataPresenter::Service.new(
        'service_name' => 'acceptance-tests-date',
        'test_escaping' => "I don't know"
      )
    )
    allow(service_provisioner).to receive(:secret_key_base).and_return(
      'fdfdd491d611aa1abef54cbf24a709a1bb31ff881a487f8c58c69399202b08f77019920f481e17b40dd7452361055534b9f91f172719ed98a088498242f96f59'
    )
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[])
      .with('SUBMISSION_ENCRYPTION_KEY')
      .and_return('65a27a35-c475-48b9-9a20-30142f14')
    allow(ENV).to receive(:[])
      .with('SERVICE_SENTRY_DSN_TEST')
      .and_return('sentry-dsn-test')
  end

  describe '#generate' do
    let(:tmp_dir) do
      Rails.root.join('tmp', 'kubernetes_configuration')
    end

    before do
      FileUtils.mkdir_p(tmp_dir)
      kubernetes_configuration.generate(destination: tmp_dir)
    end

    after do |example_group|
      # We don't want to delete if the test fail so we can verify
      # the contents of the directory.
      FileUtils.rm_r(tmp_dir) unless example_group.exception.present?
    end

    context 'service.yaml' do
      let(:service_yaml) do
        YAML.load_file(
          Rails.root.join(
            'spec',
            'fixtures',
            'kubernetes_configuration',
            'service.yaml'
          )
        )
      end

      it 'generates the service.yaml' do
        expect('service.yaml').to be_generated_in(
          tmp_dir
        ).with_content(service_yaml)
      end
    end

    context 'deployment.yaml' do
      let(:deployment_yaml) do
        YAML.load_file(
          Rails.root.join(
            'spec',
            'fixtures',
            'kubernetes_configuration',
            'deployment.yaml'
          )
        )
      end

      it 'generates the deployment.yaml' do
        expect('deployment.yaml').to be_generated_in(
          tmp_dir
        ).with_content(deployment_yaml)
      end
    end

    context 'ingress.yaml' do
      let(:ingress_yaml) do
        YAML.load_file(
          Rails.root.join(
            'spec',
            'fixtures',
            'kubernetes_configuration',
            'ingress.yaml'
          )
        )
      end

      it 'generates the ingress.yaml' do
        expect('ingress.yaml').to be_generated_in(
          tmp_dir
        ).with_content(ingress_yaml)
      end
    end

    context 'service_monitor.yaml' do
      let(:service_monitor_yaml) do
        YAML.load_file(
          Rails.root.join(
            'spec',
            'fixtures',
            'kubernetes_configuration',
            'service_monitor.yaml'
          )
        )
      end

      it 'generates the service_monitor.yaml' do
        expect('service_monitor.yaml').to be_generated_in(
          tmp_dir
        ).with_content(service_monitor_yaml)
      end
    end

    context 'config_map.yaml' do
      let(:config_map_yaml) do
        YAML.load_file(
          Rails.root.join(
            'spec',
            'fixtures',
            'kubernetes_configuration',
            'config_map.yaml'
          )
        )
      end

      it 'generates the config_map.yaml' do
        expect('config_map.yaml').to be_generated_in(
          tmp_dir
        ).with_content(config_map_yaml)
      end
    end

    context 'secrets.yaml' do
      let(:secrets_yaml) do
        YAML.load_file(
          Rails.root.join(
            'spec',
            'fixtures',
            'kubernetes_configuration',
            'secrets.yaml'
          )
        )
      end

      it 'generates the secrets.yaml' do
        expect('secrets.yaml').to be_generated_in(
            tmp_dir
          ).with_content(secrets_yaml)
      end
    end
  end
end
