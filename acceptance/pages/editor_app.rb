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

  element :service_name, '#form-navigation-heading'
  element :name_field, :field, 'What is the name of this form?'
  element :create_service_button, :button, 'Create a new form'

  element :settings_link, :link, 'Settings'
  element :form_information_link, :link, 'Form information'
  element :form_name_field, :field, 'Form name'
  element :save_button, :button, 'Save'

  element :page_url_field, :field, 'The page’s relative url - it must not contain any spaces', visible: false
  element :new_page_form, '#new_page', visible: false

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
