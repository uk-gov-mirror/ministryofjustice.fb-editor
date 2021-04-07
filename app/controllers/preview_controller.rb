class PreviewController < PermissionsController
  layout 'metadata_presenter/application'
  self.per_form_csrf_tokens = false
end
