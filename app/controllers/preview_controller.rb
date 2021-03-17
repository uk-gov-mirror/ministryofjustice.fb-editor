class PreviewController < ApplicationController
  layout 'metadata_presenter/application'

  def service
    @service ||= MetadataPresenter::Service.new(service_metadata, editor: editable?)
  end
  helper_method :service
end
