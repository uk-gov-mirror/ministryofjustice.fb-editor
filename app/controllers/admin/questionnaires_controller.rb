module Admin
  class QuestionnairesController < Admin::ApplicationController
    include MetadataVersionHelper

    helper_method :service_name_for

    def index
      response = MetadataApiClient::Questionnaire.all_questionnaires(
        page:,
        per_page:
      )

      @questionnaires = Kaminari.paginate_array(
        response[:questionnaires],
        total_count: response[:total_questionnaires]
      ).page(page).per(per_page)
    end

    private

    def service_name_for(service_id)
      service_names[service_id] ||=
        begin
          MetadataApiClient::Service.latest_version(service_id)['service_name'].presence || service_id
        rescue StandardError
          service_id
        end
    end

    def service_names
      @service_names ||= {}
    end

    def page
      @page ||= params[:page] || 1
    end

    def per_page
      params[:per_page] || 20
    end
  end
end
