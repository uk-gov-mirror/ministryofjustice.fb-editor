RSpec.describe EmailSettingsUpdater do
  subject(:email_settings_updater) do
    described_class.new(
      email_settings: EmailSettings.new(
        params.merge(
          service: service,
          deployment_environment: 'dev'
        )
      ),
      service: service
    )
  end
  let(:params) { {} }

  describe '#create_or_update' do
    context 'email output' do
      context 'when email output exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_email_output,
            service_id: service.service_id
          )
        end

        context 'when a user updates the value' do
          let(:params) do
            {
              service_email_output: 'aragorn@middle-earth.uk'
            }
          end

          it 'updates the service configuration subject' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_output])
          end
        end

        context 'when user removes the value' do
          let(:params) do
            {
              service_email_output: ''
            }
          end

          it 'removes from the database' do
            email_settings_updater.create_or_update!

            expect {
              service_configuration.reload
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context 'when email output does not exist in the db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'SERVICE_EMAIL_OUTPUT'
          )
        end

        context 'when an user adds the value' do
          let(:params) do
            {
              service_email_output: 'aragorn@middle-earth.uk'
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'updates the service configuration subject' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_output])
          end
        end

        context 'when user removes the value' do
          let(:params) do
            {
              service_email_output: ''
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'updates the service configuration subject' do
            expect(service_configuration).to be_blank
          end
        end
      end
    end

    context 'email pdf subheading' do
      context 'when email pdf subheading exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_email_pdf_subheading,
            service_id: service.service_id
          )
        end

        context 'when a user updates the value' do
          let(:params) do
            {
              service_email_pdf_subheading: 'A subterranean subheading'
            }
          end

          it 'updates the service configuration pdf subheading' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_pdf_subheading])
          end
        end

        context 'when user removes the value' do
          let(:params) do
            {
              service_email_pdf_subheading: ''
            }
          end

          it 'removes from the database' do
            email_settings_updater.create_or_update!

            expect {
              service_configuration.reload
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context 'when email pdf subheading does not exist in the db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'SERVICE_EMAIL_PDF_SUBHEADING'
          )
        end

        context 'when a user adds the value' do
          let(:params) do
            {
              service_email_pdf_subheading: 'A subterranean subheading'
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'updates the service configuration pdf subheading' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_pdf_subheading])
          end
        end

        context 'when user removes the value' do
          let(:params) do
            {
              service_email_pdf_subheading: ''
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'updates the service configuration pdf subheading' do
            expect(service_configuration).to be_blank
          end
        end
      end
    end

    context 'email pdf subheading' do
      context 'when email pdf subheading exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_email_pdf_subheading,
            service_id: service.service_id
          )
        end

        context 'when a user updates the value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_pdf_subheading: 'A subterranean subheading'
            }
          end

          it 'updates the service configuration pdf subheading' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_pdf_subheading])
          end
        end

        context 'when user removes the value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_pdf_subheading: ''
            }
          end

          it 'removes from the database' do
            email_settings_updater.create_or_update!

            expect {
              service_configuration.reload
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context 'when email pdf subheading does not exist in the db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'SERVICE_EMAIL_PDF_SUBHEADING'
          )
        end

        context 'when a user adds the value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_pdf_subheading: 'A subterranean subheading'
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'updates the service configuration pdf subheading' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_pdf_subheading])
          end
        end

        context 'when user removes the value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_pdf_subheading: ''
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'updates the service configuration pdf subheading' do
            expect(service_configuration).to be_blank
          end
        end
      end
    end

    context 'email subject' do
      context 'when email subject exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_email_subject,
            service_id: service.service_id
          )
        end

        context 'when a user updates the value' do
          let(:params) do
            {
              service_email_subject: 'This is an awesome email subject'
            }
          end

          it 'updates the service configuration subject' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_subject])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              service_email_subject: ''
            }
          end

          it 'shows the default subject' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq("Submission from #{service.service_name}")
          end
        end
      end

      context 'when email subject does not exist in db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'SERVICE_EMAIL_SUBJECT'
          )
        end

        context 'when an user adds a value' do
          let(:params) do
            {
              service_email_subject: 'This is an awesome email subject'
            }
          end

          before do
            email_settings_updater.create_or_update!
          end

          it 'creates the service configuration subject' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_subject])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              service_email_subject: ''
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'shows the default subject' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq("Submission from #{service.service_name}")
          end
        end
      end
    end

    context 'email body' do
      context 'when email body exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_email_body,
            service_id: service.service_id
          )
        end

        context 'when an user updates the value' do
          let(:params) do
            {
              service_email_body: 'Heads and shoulders, knees and toes'
            }
          end

          it 'updates the service configuration body' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_body])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              service_email_body: ''
            }
          end

          it 'shows the default body' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq("Please find attached a submission sent from #{service.service_name}")
          end
        end
      end

      context 'when email body does not exist in db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'SERVICE_EMAIL_BODY'
          )
        end

        context 'when a user adds a value' do
          let(:params) do
            {
              service_email_body: 'Heads and shoulders, knees and toes'
            }
          end

          before do
            email_settings_updater.create_or_update!
          end

          it 'creates the service configuration body' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_body])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              service_email_body: ''
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'shows the default subject' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq("Please find attached a submission sent from #{service.service_name}")
          end
        end
      end
    end

    context 'email pdf heading' do
      context 'when email pdf heading exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_email_pdf_heading,
            service_id: service.service_id
          )
        end

        context 'when a user updates the value' do
          let(:params) do
            {
              service_email_pdf_heading: 'We love kakapos'
            }
          end

          it 'updates the service configuration pdf heading' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_pdf_heading])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              service_email_pdf_heading: ''
            }
          end

          it 'shows the default pdf heading' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq("Submission for #{service.service_name}")
          end
        end
      end

      context 'when email pdf heading does not exist in db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'SERVICE_EMAIL_PDF_HEADING'
          )
        end

        context 'when a user adds a value' do
          let(:params) do
            {
              service_email_pdf_heading: 'We love kakapos'
            }
          end

          before do
            email_settings_updater.create_or_update!
          end

          it 'creates the service configuration pdf heading' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_pdf_heading])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              service_email_pdf_heading: ''
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'shows the default pdf heading' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq("Submission for #{service.service_name}")
          end
        end
      end
    end

    context 'email body' do
      context 'when email body exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_email_body,
            service_id: service.service_id
          )
        end

        context 'when an user updates the value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_body: 'Heads and shoulders, knees and toes'
            }
          end

          it 'updates the service configuration body' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_body])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_body: ''
            }
          end

          it 'shows the default body' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq("Please find attached a submission sent from #{service.service_name}")
          end
        end
      end

      context 'when email body does not exist in db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'SERVICE_EMAIL_BODY'
          )
        end

        context 'when a user adds a value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_body: 'Heads and shoulders, knees and toes'
            }
          end

          before do
            email_settings_updater.create_or_update!
          end

          it 'creates the service configuration body' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_body])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_body: ''
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'shows the default subject' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq("Please find attached a submission sent from #{service.service_name}")
          end
        end
      end
    end

    context 'email pdf heading' do
      context 'when email pdf heading exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_email_pdf_heading,
            service_id: service.service_id
          )
        end

        context 'when a user updates the value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_pdf_heading: 'We love kakapos'
            }
          end

          it 'updates the service configuration pdf heading' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_pdf_heading])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_pdf_heading: ''
            }
          end

          it 'shows the default pdf heading' do
            email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq("Submission for #{service.service_name}")
          end
        end
      end

      context 'when email pdf heading does not exist in db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'SERVICE_EMAIL_PDF_HEADING'
          )
        end

        context 'when a user adds a value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_pdf_heading: 'We love kakapos'
            }
          end

          before do
            email_settings_updater.create_or_update!
          end

          it 'creates the service configuration pdf heading' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:service_email_pdf_heading])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              deployment_environment: 'dev',
              service_email_pdf_heading: ''
            }
          end
          before { email_settings_updater.create_or_update! }

          it 'shows the default pdf heading' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq("Submission for #{service.service_name}")
          end
        end
      end
    end
  end
end
