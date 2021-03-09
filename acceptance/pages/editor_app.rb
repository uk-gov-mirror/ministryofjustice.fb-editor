class EmailSubmissionSection < SitePrism::Section
  element :send_by_email_on_test, :checkbox, 'Send by email on Test', visible: false
  element :send_by_email_on_live, :checkbox, 'Send by email on Live', visible: false
  element :configure_link_on_test, '#configure-dev'
  element :configure_link_on_live, '#configure-production'
  element :send_email_to_field, :field, 'Send email to'
  element :email_subject_field, :field, 'Email subject'
  element :email_body_field, :field, 'Email text'
  element :email_pdf_heading_field, :field, 'Heading'
  element :email_pdf_subheading_field, :field, 'Subheading'
  element :save_button, :button, 'Save'
  elements :error_messages, '.govuk-error-message'
end

class EditorApp < SitePrism::Page
  if ENV['ACCEPTANCE_TESTS_USER'] && ENV['ACCEPTANCE_TESTS_PASSWORD']
    set_url ENV['ACCEPTANCE_TESTS_EDITOR_APP'] % {
      user: ENV['ACCEPTANCE_TESTS_USER'],
      password: ENV['ACCEPTANCE_TESTS_PASSWORD']
    }
  else
    set_url ENV['ACCEPTANCE_TESTS_EDITOR_APP']
  end

  element :service_name, '#form-navigation-heading'
  element :name_field, :field, 'What is the name of this form?'
  element :create_service_button, :button, 'Create a new form'

  element :settings_link, :link, 'Settings'
  element :form_information_link, :link, 'Form information'
  element :form_name_field, :field, 'Form name'
  element :save_button, :button, 'Save'

  element :submission_settings_link, :link, 'Submission settings'
  element :send_by_email_link, :link, 'Send by email'

  element :page_url_field, :field, 'The page’s relative url - it must not contain any spaces', visible: false
  element :new_page_form, '#new_page', visible: false

  section :email_submission_test, EmailSubmissionSection, '#email-submission-dev'
  section :email_submission_live, EmailSubmissionSection, '#email-submission-production'

  def edit_service_link(service_name)
    find("#service-#{service_name.parameterize} .edit")
  end

  def modal_create_service_button
    all('.ui-dialog-buttonpane button').first
  end

  # Getting Selenium::WebDriver::Error::ElementNotInteractableError
  # when using something like find_field('page_component_type', type: :hidden)
  def set_page_type_field(value)
    page.execute_script("document.getElementById('page_page_type').value = '#{value}'")
  end

  def set_component_type_field(value)
    page.execute_script("document.getElementById('page_component_type').value = '#{value}'")
  end

  def submit_new_page
    page.execute_script("document.querySelector(\"#new_page input[type='submit']\").click")
  end

  def set_invisible_field_by_id(id, value)
    page.execute_script("document.getElementById('#{id}').value = '#{value}'")
  end

end
