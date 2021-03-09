RSpec.describe EmailSettings do
  subject(:email_settings) do
    described_class.new(
      params.merge(service: service)
    )
  end
  let(:params) { {} }

  describe '#valid?' do
    context 'when send by email is ticked' do
      before do
        allow(email_settings).to receive(:send_by_email).and_return('1')
      end

      it 'allow emails' do
        should allow_values(
          'frodo@shire.uk'
        ).for(:service_email_output)
      end

      it 'do not allow malformed emails' do
        should_not allow_values(
          'organa', 'leia'
        ).for(:service_email_output)
      end

      it 'do not allow blanks' do
        should_not allow_values(
          nil, ''
        ).for(:service_email_output)
      end
    end

    context 'when send by email is unticked' do
      before do
        allow(email_settings).to receive(:send_by_email).and_return('0')
      end

      it 'do not allow malformed emails' do
        should_not allow_values(
          'organa', 'leia'
        ).for(:service_email_output)
      end

      it 'allow blanks' do
        should allow_values(
          nil, ''
        ).for(:service_email_output)
      end
    end

    context 'deployment environment' do
      it 'allow dev and production' do
        should allow_values('dev', 'production').for(:deployment_environment)
      end

      it 'do not allow enything else' do
        should_not allow_values(
          nil, '', 'something-else', 'staging', 'live', 'test'
        ).for(:deployment_environment)
      end
    end
  end

  describe '#service_email_output' do
    context 'when email is empty' do
      it 'returns nil' do
        expect(email_settings.service_email_output).to eq('')
      end
    end

    context 'when user submits a value' do
      let(:params) do
        {
          deployment_environment: 'dev',
          service_email_output: 'han.solo@milleniumfalcon.uk'
        }
      end

      it 'shows the submitted value' do
        expect(
          email_settings.service_email_output
        ).to eq('han.solo@milleniumfalcon.uk')
      end
    end

    context 'when a value already exists in the db' do
      let(:params) { {deployment_environment: 'dev'} }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :dev,
          :service_email_output,
          service_id: service.service_id
        )
      end

      it 'shows the value in the db' do
        expect(
          email_settings.service_email_output
        ).to eq(service_configuration.decrypt_value)
      end
    end
  end

  describe '#service_email_output' do
    context 'when email is empty' do
      it 'returns nil' do
        expect(email_settings.service_email_output).to eq('')
      end
    end

    context 'when user submits a value' do
      let(:params) do
        { deployment_environment: 'production',
          service_email_output: 'han.solo@milleniumfalcon.uk'
        }
      end

      it 'shows the submitted value' do
        expect(
          email_settings.service_email_output
        ).to eq('han.solo@milleniumfalcon.uk')
      end
    end

    context 'when a value already exists in the db' do
      let(:params) { {deployment_environment: 'production'} }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :production,
          :service_email_output,
          service_id: service.service_id
        )
      end

      it 'shows the value in the db' do
        expect(
          email_settings.service_email_output
        ).to eq(service_configuration.decrypt_value)
      end
    end
  end

  describe '#service_email_subject' do
    context 'when subject is empty' do
      it 'shows the default value' do
        expect(email_settings.service_email_subject).to eq(
          "Submission from #{service.service_name}"
        )
      end
    end

    context 'when user submits a value' do
      let(:params) do
        {
          deployment_environment: 'dev',
          service_email_subject: 'Never tell me the odds.'
        }
      end

      it 'shows the submitted value' do
        expect(
          email_settings.service_email_subject
        ).to eq('Never tell me the odds.')
      end
    end

    context 'when a value already exists in the db' do
      let(:params) { {deployment_environment: 'dev'} }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :dev,
          :service_email_subject,
          service_id: service.service_id
        )
      end

      it 'shows the value in the db' do
        expect(
          email_settings.service_email_subject
        ).to eq(service_configuration.decrypt_value)
      end
    end
  end

  describe '#service_email_subject' do
    context 'when subject is empty' do
      it 'shows the default value' do
        expect(email_settings.service_email_subject).to eq(
          "Submission from #{service.service_name}"
        )
      end
    end

    context 'when user submits a value' do
      let(:params) do
        { deployment_environment: 'production',
          service_email_subject: 'Never tell me the odds.'
        }
      end

      it 'shows the submitted value' do
        expect(
          email_settings.service_email_subject
        ).to eq('Never tell me the odds.')
      end
    end

    context 'when a value already exists in the db' do
      let(:params) { {deployment_environment: 'production'} }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :production,
          :service_email_subject,
          service_id: service.service_id
        )
      end

      it 'shows the value in the db' do
        expect(
          email_settings.service_email_subject
        ).to eq(service_configuration.decrypt_value)
      end
    end
  end

  describe '#service_email_body' do
    context 'when body is empty' do
      it 'shows the default value' do
        expect(email_settings.service_email_body).to eq(
          "Please find attached a submission sent from #{service.service_name}"
        )
      end
    end

    context 'when user submits a value' do
      let(:params) do
        {
          deployment_environment: 'dev',
          service_email_body: 'Please find attached the Death star plans'
          }
      end

      it 'shows the submitted value' do
        expect(
          email_settings.service_email_body
        ).to eq('Please find attached the Death star plans')
      end
    end

    context 'when a value already exists in the db' do
      let(:params) { {deployment_environment: 'dev'} }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :dev,
          :service_email_body,
          service_id: service.service_id
        )
      end

      it 'shows the value in the db' do
        expect(
          email_settings.service_email_body
        ).to eq(service_configuration.decrypt_value)
      end
    end
  end

  describe '#service_email_body' do
    context 'when body is empty' do
      it 'shows the default value' do
        expect(email_settings.service_email_body).to eq(
          "Please find attached a submission sent from #{service.service_name}"
        )
      end
    end

    context 'when user submits a value' do
      let(:params) do
        {
          deployment_environment: 'production',
          service_email_body: 'Please find attached the Death star plans'
        }
      end

      it 'shows the submitted value' do
        expect(
          email_settings.service_email_body
        ).to eq('Please find attached the Death star plans')
      end
    end

    context 'when a value already exists in the db' do
      let(:params) { {deployment_environment: 'production'} }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :production,
          :service_email_body,
          service_id: service.service_id
        )
      end

      it 'shows the value in the db' do
        expect(
          email_settings.service_email_body
        ).to eq(service_configuration.decrypt_value)
      end
    end
  end

  describe '#service_email_pdf_heading' do
    context 'when body is empty' do
      it 'shows the default value' do
        expect(email_settings.service_email_pdf_heading).to eq(
          "Submission for #{service.service_name}"
        )
      end
    end

    context 'when user submits a value' do
      let(:params) do
        {
          deployment_environment: 'dev',
          service_email_pdf_heading: 'Death star plans'
        }
      end

      it 'shows the submitted value' do
        expect(
          email_settings.service_email_pdf_heading
        ).to eq('Death star plans')
      end
    end

    context 'when a value already exists in the db' do
      let(:params) { {deployment_environment: 'dev'} }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :dev,
          :service_email_pdf_heading,
          service_id: service.service_id
        )
      end

      it 'shows the value in the db' do
        expect(
          email_settings.service_email_pdf_heading
        ).to eq(service_configuration.decrypt_value)
      end
    end
  end

  describe '#service_email_pdf_heading' do
    context 'when body is empty' do
      it 'shows the default value' do
        expect(email_settings.service_email_pdf_heading).to eq(
          "Submission for #{service.service_name}"
        )
      end
    end

    context 'when user submits a value' do
      let(:params) do
        {
          deployment_environment: 'production',
          service_email_pdf_heading: 'Death star plans'
        }
      end

      it 'shows the submitted value' do
        expect(
          email_settings.service_email_pdf_heading
        ).to eq('Death star plans')
      end
    end

    context 'when a value already exists in the db' do
      let(:params) { {deployment_environment: 'production'} }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :production,
          :service_email_pdf_heading,
          service_id: service.service_id
        )
      end

      it 'shows the value in the db' do
        expect(
          email_settings.service_email_pdf_heading
        ).to eq(service_configuration.decrypt_value)
      end
    end
  end

  describe '#service_email_pdf_subheading' do
    context 'when body is empty' do
      it 'shows the default value' do
        expect(email_settings.service_email_pdf_subheading).to eq('')
      end
    end

    context 'when user submits a value' do
      let(:params) do
        {
          deployment_environment: 'dev',
          service_email_pdf_subheading: 'Rebellion ships'
        }
      end

      it 'shows the submitted value' do
        expect(
          email_settings.service_email_pdf_subheading
        ).to eq('Rebellion ships')
      end
    end

    context 'when a value already exists in the db' do
      let(:params) { {deployment_environment: 'dev'} }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :dev,
          :service_email_pdf_subheading,
          service_id: service.service_id
        )
      end

      it 'shows the value in the db' do
        expect(
          email_settings.service_email_pdf_subheading
        ).to eq(service_configuration.decrypt_value)
      end
    end
  end

  describe '#service_email_pdf_subheading' do
    context 'when body is empty' do
      it 'shows the default value' do
        expect(email_settings.service_email_pdf_subheading).to eq('')
      end
    end

    context 'when user submits a value' do
      let(:params) do
        {
          deployment_environment: 'production',
          service_email_pdf_subheading: 'Rebellion ships'
        }
      end

      it 'shows the submitted value' do
        expect(
          email_settings.service_email_pdf_subheading
        ).to eq('Rebellion ships')
      end
    end

    context 'when a value already exists in the db' do
      let(:params) { {deployment_environment: 'production'} }
      let!(:service_configuration) do
        create(
          :service_configuration,
          :production,
          :service_email_pdf_subheading,
          service_id: service.service_id
        )
      end

      it 'shows the value in the db' do
        expect(
          email_settings.service_email_pdf_subheading
        ).to eq(service_configuration.decrypt_value)
      end
    end
  end
end
