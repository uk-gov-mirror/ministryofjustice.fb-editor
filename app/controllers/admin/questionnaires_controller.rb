module Admin
  class QuestionnairesController < Admin::ApplicationController
    include MetadataVersionHelper

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

    def page
      params[:page] || 1
    end

    def per_page
      params[:per_page] || 20
    end
  end
end
