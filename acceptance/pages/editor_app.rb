class EditorApp < SitePrism::Page
  if ENV['ACCEPTANCE_TESTS_USER'] && ENV['ACCEPTANCE_TESTS_PASSWORD']
    set_url ENV['ACCEPTANCE_TESTS_EDITOR_APP'] % {
      user: ENV['ACCEPTANCE_TESTS_USER'],
      password: ENV['ACCEPTANCE_TESTS_PASSWORD']
    }
  else
    set_url ENV['ACCEPTANCE_TESTS_EDITOR_APP']
  end

  element :sign_in_button, :button, 'Sign in'
  element :sign_in_email_field, :field, 'Email:'
  element :sign_in_submit, :button, 'Sign In'

  element :email_address_field, :field, 'Email address'
  element :password_field, :field, 'Password'
  element :login_continue_button, :button, 'Continue'

  element :service_name, '#form-navigation-heading'
  element :name_field, :field, 'Give your form a name'
  element :create_service_button, :button, 'Create a new form'

  element :pages_link, :link, 'Pages'
  element :settings_link, :link, 'Settings'
  element :form_details_link, :link, 'Form details'
  element :form_name_field, :field, 'Form name'
  element :save_button, :button, 'Save'
  element :preview_form_button, :link, 'Preview form'

  element :submission_settings_link, :link, 'Submission settings'
  element :send_by_email_link, :link, 'Send by email'

  element :page_url_field, :field, 'What will be the URL for this page?'
  element :new_page_form, '#new_page', visible: false

  element :add_page, :button, 'Add page'
  element :add_single_question,
          :xpath,
          "//span[@class='ui-menu-item-wrapper' and contains(.,'Single question page')]"
  element :add_multiple_question,
          :xpath,
          "//a[@class='ui-menu-item-wrapper' and contains(.,'Multiple question page')]"
  element :add_check_answers,
          :xpath,
          "//a[@class='ui-menu-item-wrapper' and contains(.,'Check answers page')]"
  element :add_confirmation,
          :xpath,
          "//a[@class='ui-menu-item-wrapper' and contains(.,'Confirmation page')]"

  element :add_single_question_text, :link, 'Text', visible: false
  element :add_single_question_text_area, :link, 'Textarea', visible: false
  element :add_single_question_number, :link, 'Number', visible: false
  element :add_single_question_date, :link, 'Date', visible: false
  element :add_single_question_radio, :link, 'Radio buttons', visible: false
  element :add_single_question_checkboxes, :link, 'Checkboxes', visible: false

  elements :add_page_submit_button, :button, 'Add page'
  element :save_page_button, :xpath, '//input[@value="Save"]'

  elements :radio_options, :xpath, '//input[@type="radio"]', visible: false
  elements :checkboxes_options, :xpath, '//input[@type="checkbox"]', visible: false

  elements :question_heading, '.EditableElement'
  elements :all_hints, '.govuk-hint'
  elements :editable_options, '.EditableComponentCollectionItem label'
  element :question_hint, '.govuk-hint'

  elements :form_pages, '.form-step'
  elements :form_urls, '.form-step a.govuk-link'
  elements :preview_page_images, '.form-step img.body'
  element :three_dots_button, '.form-step_button'
  element :preview_page_link, :link, 'Preview page'
  element :delete_page_link, :link, 'Delete page...'
  element :delete_page_modal_button, :button, 'Delete page'

  def edit_service_link(service_name)
    find("#service-#{service_name.parameterize} .edit")
  end

  def modal_create_service_button
    all('.ui-dialog-buttonpane button').first
  end
end
