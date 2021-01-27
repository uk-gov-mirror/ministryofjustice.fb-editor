# coding: utf-8
class EditorApp < SitePrism::Page
  if ENV['ACCEPTANCE_TESTS_USER'] && ENV['ACCEPTANCE_TESTS_PASSWORD']
    set_url ENV['ACCEPTANCE_TESTS_EDITOR_APP'] % {
      user: ENV['ACCEPTANCE_TESTS_USER'],
      password: ENV['ACCEPTANCE_TESTS_PASSWORD']
    }
  else
    set_url ENV['ACCEPTANCE_TESTS_EDITOR_APP']
  end

  element :service_name, 'main h1.service-name'
  element :service_name_navigation_heading, '#form-navigation-heading'
  element :name_field, :field, 'What is the name of this form?'
  element :create_service_button, :button, 'Create a new form'

  element :settings_link, :link, 'Settings'
  element :form_information_link, :link, 'Form information'
  element :form_name_field, :field, 'Form name'
  element :save_button, :button, 'Save'

  element :page_url_field, :field, 'The page’s relative url - it must not contain any spaces'
  element :add_page_button, :button, 'Add page'

  def edit_service_link(service_name)
    find("#service-#{service_name.parameterize} .edit")
  end

  def modal_create_service_button
    all('.ui-dialog-buttonpane button').first
  end
end
