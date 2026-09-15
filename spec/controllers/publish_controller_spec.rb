require 'rails_helper'

RSpec.describe PublishController, type: :controller do
  let(:current_user) do
    double(id: service.created_by, email: 'jane.smith@digital.justice.gov.uk')
  end
  let(:service_id) { service.service_id }

  before do
    allow(controller).to receive(:service).and_return(service)
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(controller).to receive(:require_user!).and_return(true)
    allow(controller).to receive(:authorised_access).and_return(true)
    allow(controller).to receive(:service_autocomplete_items).and_return([])
  end

  # A helper to create a ServiceConfiguration "flag" record (REVOKED etc.)
  def create_flag(name)
    create(
      :service_configuration,
      :production,
      service_id:,
      name:,
      value: '1'
    )
  end

  describe '#can_publish_to_live' do
    subject { controller.can_publish_to_live }

    context 'when REVOKED flag is present' do
      before { create_flag('REVOKED') }

      it 'returns false even when APPROVED_TO_GO_LIVE is also present' do
        create_flag('APPROVED_TO_GO_LIVE')
        expect(subject).to be(false)
      end
    end

    context 'when APPROVED_TO_GO_LIVE is present (and not revoked)' do
      before { create_flag('APPROVED_TO_GO_LIVE') }

      it 'returns true' do
        expect(subject).to be(true)
      end

      it 'still returns true when AWAITING_APPROVAL is also present (approval wins)' do
        create_flag('AWAITING_APPROVAL')
        expect(subject).to be(true)
      end
    end

    context 'when AWAITING_APPROVAL is present (and not revoked/approved)' do
      before { create_flag('AWAITING_APPROVAL') }

      it 'returns false' do
        expect(subject).to be(false)
      end
    end

    context 'when no flags are set' do
      it 'returns false when there is no production publish service' do
        expect(subject).to be(false)
      end

      it 'returns true when a production publish service already exists' do
        create(:publish_service, :production, :completed, service_id:)
        expect(subject).to be(true)
      end

      it 'ignores dev-only publish services' do
        create(:publish_service, :dev, :completed, service_id:)
        expect(subject).to be(false)
      end
    end
  end

  describe '#show_confirmation?' do
    subject { controller.show_confirmation? }

    it 'returns true when AWAITING_APPROVAL is present' do
      create_flag('AWAITING_APPROVAL')
      expect(subject).to be(true)
    end

    it 'returns false when AWAITING_APPROVAL is absent' do
      expect(subject).to be(false)
    end
  end

  describe '#text_for_environment' do
    it "returns 'Test' for dev" do
      expect(controller.text_for_environment('dev')).to eq('Test')
    end

    it "returns 'Live' for production" do
      expect(controller.text_for_environment('production')).to eq('Live')
    end

    it "returns 'Live' for anything that is not dev" do
      expect(controller.text_for_environment('something-else')).to eq('Live')
    end
  end

  describe '#form_url' do
    before do
      allow(controller).to receive(:platform_environment).and_return('test')
      allow(controller).to receive(:service_slug).and_return('my-form')
    end

    it 'builds a dev url with the .dev. subdomain' do
      expect(controller.form_url('dev'))
        .to eq('https://my-form.dev.test.form.service.justice.gov.uk')
    end

    it 'builds a production url without the .dev. subdomain' do
      expect(controller.form_url('production'))
        .to eq('https://my-form.test.form.service.justice.gov.uk')
    end
  end

  describe '#prepare_ms_list_integration' do
    let(:env) { 'dev' }

    subject { controller.prepare_ms_list_integration(env) }

    context 'when there is no MS_SITE_ID configuration' do
      it 'skips integration and returns true' do
        expect(controller).not_to receive(:create_ms_list_and_drive)
        expect(subject).to be(true)
      end
    end

    context 'when MS_SITE_ID exists but graph sending is switched off' do
      before do
        create(:service_configuration, :dev, :ms_site_id, service_id:)
        create(
          :submission_setting, :dev, :do_not_send_to_graph_api, service_id:
        )
      end

      it 'skips integration and returns true' do
        expect(controller).not_to receive(:create_ms_list_and_drive)
        expect(subject).to be(true)
      end
    end

    context 'when MS_SITE_ID exists and graph sending is on' do
      before do
        create(:service_configuration, :dev, :ms_site_id, service_id:)
        create(:submission_setting, :dev, :send_to_graph_api, service_id:)
      end

      context 'when there is no published version yet' do
        it 'does nothing and returns true' do
          expect(controller).not_to receive(:create_ms_list_and_drive)
          expect(subject).to be(true)
        end
      end

      context 'when the latest published version matches the current version' do
        before do
          create(
            :publish_service, :dev, :completed,
            service_id:, version_id: service.version_id
          )
        end

        it 'does nothing and returns true' do
          expect(controller).not_to receive(:create_ms_list_and_drive)
          expect(subject).to be(true)
        end
      end

      context 'when the latest published version differs from the current version' do
        before do
          create(
            :publish_service, :dev, :completed,
            service_id:, version_id: SecureRandom.uuid
          )
        end

        it 'creates the list/drive and returns the result of that creation' do
          allow(controller).to receive(:create_ms_list_and_drive).and_return(true)
          allow(NewListMailer).to receive(:new_ms_list_created)
            .and_return(double(deliver_later: nil))

          expect(controller).to receive(:create_ms_list_and_drive)
            .with('ms-site-id-value', service, 'dev')
          expect(subject).to be(true)
        end

        it 'sends the "new list created" email only when creation succeeded' do
          allow(controller).to receive(:create_ms_list_and_drive).and_return(true)
          mailer = double(deliver_later: nil)
          expect(NewListMailer).to receive(:new_ms_list_created).and_return(mailer)
          expect(mailer).to receive(:deliver_later)

          subject
        end

        it 'does not send the email when creation failed and returns false' do
          allow(controller).to receive(:create_ms_list_and_drive).and_return(false)
          expect(NewListMailer).not_to receive(:new_ms_list_created)

          expect(subject).to be(false)
        end
      end
    end
  end

  describe '#create_ms_list_and_drive' do
    let(:env) { 'dev' }
    let(:adapter) { instance_double(MicrosoftGraphAdapter) }

    before do
      allow(MicrosoftGraphAdapter).to receive(:new).and_return(adapter)
    end

    def response_double(status, id: nil)
      double(status:, body: { 'id' => id }.to_json)
    end

    context 'when both the list and drive are created (HTTP 201)' do
      before do
        allow(adapter).to receive(:post_list_columns)
          .and_return(response_double(201, id: 'list-123'))
        allow(adapter).to receive(:create_drive)
          .and_return(response_double(201, id: 'drive-456'))
      end

      it 'returns true' do
        expect(controller.create_ms_list_and_drive('site', service, env)).to be(true)
      end

      it 'saves the returned list id in an MS_LIST_ID configuration' do
        controller.create_ms_list_and_drive('site', service, env)
        config = ServiceConfiguration.find_by(
          service_id:, deployment_environment: env, name: 'MS_LIST_ID'
        )
        expect(config.decrypt_value).to eq('list-123')
      end

      it 'saves the returned drive id in an MS_DRIVE_ID configuration' do
        controller.create_ms_list_and_drive('site', service, env)
        config = ServiceConfiguration.find_by(
          service_id:, deployment_environment: env, name: 'MS_DRIVE_ID'
        )
        expect(config.decrypt_value).to eq('drive-456')
      end
    end

    context 'when the list creation fails (non-201)' do
      before do
        allow(adapter).to receive(:post_list_columns)
          .and_return(response_double(500))
        allow(adapter).to receive(:create_drive)
          .and_return(response_double(201, id: 'drive-456'))
      end

      it 'returns false' do
        expect(controller.create_ms_list_and_drive('site', service, env)).to be(false)
      end
    end

    context 'when the drive creation fails (non-201)' do
      before do
        allow(adapter).to receive(:post_list_columns)
          .and_return(response_double(201, id: 'list-123'))
        allow(adapter).to receive(:create_drive)
          .and_return(response_double(500))
      end

      it 'returns false' do
        expect(controller.create_ms_list_and_drive('site', service, env)).to be(false)
      end
    end
  end

  describe '#create' do
    let(:acceptance_email) { 'fb-acceptance-tests@digital.justice.gov.uk' }
    let(:publish_creation) do
      instance_double(
        PublishServiceCreation,
        save: true,
        publish_service_id: 'publish-id',
        deployment_environment:,
        errors: double(add: nil)
      )
    end
    let(:deployment_environment) { 'dev' }

    before do
      allow(PublishServiceCreation).to receive(:new).and_return(publish_creation)
      allow(controller).to receive(:prepare_ms_list_integration).and_return(true)
      allow(PublishServiceJob).to receive(:perform_later)
      allow(NotificationService).to receive(:notify)
    end

    def do_create(env)
      post :create, params: {
        id: service_id,
        publish_service_creation: { deployment_environment: env }
      }
    end

    context 'when publishing to dev' do
      it 'queues the publish job and redirects' do
        do_create('dev')
        expect(PublishServiceJob).to have_received(:perform_later)
          .with(publish_service_id: 'publish-id')
        expect(response).to redirect_to(publish_index_path(service_id))
      end

      it 'does not send a Slack notification for dev' do
        do_create('dev')
        expect(NotificationService).not_to have_received(:notify)
      end
    end

    context 'when publishing to production and it is allowed' do
      let(:deployment_environment) { 'production' }
      before { create_flag('APPROVED_TO_GO_LIVE') }

      it 'sends a Slack notification' do
        do_create('production')
        expect(NotificationService).to have_received(:notify)
      end

      it 'does not notify when the acceptance-test user is publishing' do
        allow(current_user).to receive(:email).and_return(acceptance_email)
        do_create('production')
        expect(NotificationService).not_to have_received(:notify)
      end
    end

    context 'when publishing to production and it is NOT allowed' do
      it 'is blocked before building a PublishServiceCreation' do
        expect(PublishServiceCreation).not_to receive(:new).with(hash_including(:user_id))
        do_create('production')
      end
    end

    context 'when the Microsoft List integration cannot be prepared' do
      before do
        allow(controller).to receive(:prepare_ms_list_integration).and_return(false)
      end

      it 'adds an ms_list error, does not publish, and returns 422' do
        expect(publish_creation.errors).to receive(:add)
        do_create('dev')
        expect(PublishServiceJob).not_to have_received(:perform_later)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the publish creation fails to save' do
      let(:publish_creation) do
        instance_double(
          PublishServiceCreation,
          save: false,
          deployment_environment: 'dev',
          errors: double(add: nil)
        )
      end

      it 'does not queue a job and does not redirect' do
        do_create('dev')
        expect(PublishServiceJob).not_to have_received(:perform_later)
        expect(response).not_to be_redirect
      end
    end
  end

  describe '#publish_for_review' do
    let(:acceptance_email) { 'fb-acceptance-tests@digital.justice.gov.uk' }
    let(:all_declarations) do
      %w[declaration_1 declaration_2 declaration_3 declaration_4 declaration_5 declaration_6]
    end
    let(:publish_creation) do
      instance_double(
        PublishServiceCreation,
        valid?: true,
        save: true,
        publish_service_id: 'publish-id',
        deployment_environment: 'production',
        errors: double(add: nil)
      )
    end

    before do
      allow(PublishServiceCreation).to receive(:new).and_return(publish_creation)
      allow(controller).to receive(:prepare_ms_list_integration).and_return(true)
      allow(PublishServiceJob).to receive(:perform_later)
      allow(NotificationService).to receive(:notify)
      # review_message (used when notifying) builds a hostname, which needs these:
      allow(controller).to receive(:platform_environment).and_return('test')
      allow(controller).to receive(:service_slug).and_return('my-form')
    end

    def do_review(checkboxes)
      post :publish_for_review, params: {
        id: service_id,
        publish_for_review_declarations: { declarations_checkboxes: checkboxes }
      }
    end

    context 'when not all declarations are ticked' do
      it 'returns 422 and does not publish' do
        do_review(%w[declaration_1 declaration_2])
        expect(response).to have_http_status(:unprocessable_entity)
        expect(PublishServiceJob).not_to have_received(:perform_later)
      end

      it 'does not create the AWAITING_APPROVAL flag' do
        do_review(%w[declaration_1])
        expect(
          ServiceConfiguration.find_by(service_id:, name: 'AWAITING_APPROVAL')
        ).to be_nil
      end
    end

    context 'when all declarations are ticked' do
      it 'queues the publish job and notifies Slack' do
        do_review(all_declarations)
        expect(PublishServiceJob).to have_received(:perform_later)
          .with(publish_service_id: 'publish-id')
        expect(NotificationService).to have_received(:notify)
      end

      it 'creates the AWAITING_APPROVAL flag and redirects to the live anchor' do
        do_review(all_declarations)
        expect(
          ServiceConfiguration.find_by(service_id:, name: 'AWAITING_APPROVAL')
        ).to be_present
        expect(response).to redirect_to(
          "#{publish_index_path(service_id)}#publish-to-live"
        )
      end

      context 'when the acceptance-test user submits' do
        before { allow(current_user).to receive(:email).and_return(acceptance_email) }

        it 'does not queue a job or notify, but still awaits approval' do
          do_review(all_declarations)
          expect(PublishServiceJob).not_to have_received(:perform_later)
          expect(NotificationService).not_to have_received(:notify)
          expect(
            ServiceConfiguration.find_by(service_id:, name: 'AWAITING_APPROVAL')
          ).to be_present
        end
      end

      context 'when the Microsoft List integration cannot be prepared' do
        before do
          allow(controller).to receive(:prepare_ms_list_integration).and_return(false)
        end

        it 'returns 422 and does not publish' do
          do_review(all_declarations)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(PublishServiceJob).not_to have_received(:perform_later)
        end
      end
    end
  end

  describe '#index' do
    it 'responds successfully and assigns the publish presenters' do
      get :index, params: { id: service_id }
      expect(response).to have_http_status(:ok)
      expect(controller.view_assigns['published_dev']).to be_a(PublishServicePresenter)
      expect(controller.view_assigns['published_production']).to be_a(PublishServicePresenter)
    end
  end
end
