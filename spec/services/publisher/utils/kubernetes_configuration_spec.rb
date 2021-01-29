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
        double(name: 'ENCODED_PRIVATE_KEY', value: encoded_private_key),
        double(name: 'ENCODED_PUBLIC_KEY', value: encoded_public_key),
      ]
    )
  end
  let(:encoded_private_key) do
    Base64.strict_encode64(
      File.read(Rails.root.join('spec', 'fixtures', 'private_key'))
    )
  end
  let(:encoded_public_key) do
    Base64.strict_encode64(
      File.read(Rails.root.join('spec', 'fixtures', 'public_key'))
    )
  end

  before do
    allow(service_provisioner).to receive(:service_slug).and_return(
      'acceptance-tests-date'
    )
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
  end
end
