require_relative '../spec_helper'

feature 'Form name URL settings page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:new_service_name) { generate_service_name }
  let(:new_service_slug) { ('a'..'z').to_a.shuffle.join }
  let(:another_service_name) { generate_service_name }

  background do
    editor.load
    given_I_am_logged_in
    given_I_have_a_service
    and_I_go_to_update_the_form_details_in_settings
  end

  scenario 'current service name as input value' do
    then_I_should_see_the_current_service_name_in_the_input
  end

  scenario 'validates the service name' do
    given_I_update_the_service_name('')
    sleep 0.5
    then_I_should_see_a_validation_message_for_required('Form name')
  end

  scenario 'validates the service name min length' do
    given_I_update_the_service_name('hi')
    then_I_should_see_a_validation_message_for_min_length('Form name')
  end

  scenario 'validates the service name max length' do
    given_I_update_the_service_name('Stormtrooper Aim' * 100)
    then_I_should_see_a_validation_message_for_max_length('Form name', Editor::Service::MAXIMUM)
  end

  scenario 'updates the service in settings' do
    given_I_update_the_service_name(new_service_name)
    sleep 0.5
    then_I_should_see_the_new_service_name
  end

  scenario 'validates uniqueness of the service name' do
    given_I_have_another_service
    and_I_go_to_update_the_form_details_in_settings
    when_I_try_to_change_service_name_adding_an_existing_service_name
    then_I_should_see_the_unique_validation_message('Name has already been taken')
  end

  scenario 'current service name used as initial url value' do
    then_I_should_see_the_current_service_name_as_url
  end

  scenario 'validates the service slug' do
    given_I_update_the_service_slug('')
    then_I_should_see_a_validation_message('blank')
  end

  scenario 'validates the service slug min length' do
    given_I_update_the_service_slug('hi')
    then_I_should_see_a_validation_message_for_min_length('URL')
  end

  scenario 'validates the service slug max length' do
    given_I_update_the_service_slug('slug' * 15)
    then_I_should_see_a_validation_message_for_max_length('URL', 57)
  end

  scenario 'validates the service slug does not contain spaces' do
    given_I_update_the_service_slug('slug with whitespace')
    then_I_should_see_a_validation_message('whitespace')
  end

  scenario 'validates the service slug does not upper case characters' do
    given_I_update_the_service_slug('slug with UpPer Case')
    then_I_should_see_a_validation_message('contains_uppercase')
  end

  scenario 'validates the service slug does not special characters' do
    given_I_update_the_service_slug('slug with sp£c!al chars')
    then_I_should_see_a_validation_message('special_characters')
  end

  scenario 'validates the service slug does not start with a number' do
    given_I_update_the_service_slug('123 slug')
    then_I_should_see_a_validation_message('starts_with_number')
  end

  scenario 'updates the service slug in settings' do
    given_I_update_the_service_slug(new_service_slug)
    then_I_should_see_the_new_service_slug
  end

  def and_I_go_to_update_the_form_details_in_settings
    sleep(1)
    editor.load
    sleep(1)
    editor.edit_service_link(service_name).click
    editor.settings_link.click
    editor.form_details_link.click
  end

  def given_I_update_the_service_name(updated_service_name)
    form_name_field.set(updated_service_name)
    editor.save_button.click
  end

  def given_I_update_the_service_slug(updated_service_name)
    form_slug_field.set(updated_service_name)
    editor.save_button.click
  end

  def given_I_update_the_service_slug(updated_service_slug)
    form_url_field.set(updated_service_slug)
    editor.save_button.click
  end

  def when_I_try_to_change_service_name_adding_an_existing_service_name
    form_name_field.set(another_service_name)
    editor.save_button.click
  end

  def then_I_should_see_the_current_service_name_in_the_input
    expect(form_name_field.value).to eq(service_name)
  end

  def then_I_should_see_the_current_service_name_as_url
    expect(form_url_field.value).to eq(service_name.parameterize)
  end

  def then_I_should_see_the_new_service_name
    expect(editor.service_name.text).to eq(new_service_name)
  end

  def then_I_should_see_the_new_service_slug
    expect(form_url_field.value).to eq(new_service_slug)
  end

  def then_I_should_see_a_validation_message_for_required(attribute)
    expect(editor).to have_content(
      I18n.t('activemodel.errors.messages.blank', attribute: attribute)
    )
  end

  def then_I_should_see_a_validation_message_for_min_length(attribute)
    expect(editor).to have_content(
      I18n.t('activemodel.errors.messages.too_short', attribute: attribute, count: Editor::Service::MINIMUM)
    )
  end

  def then_I_should_see_a_validation_message_for_max_length(attribute, count)
    expect(editor).to have_content(
      I18n.t('activemodel.errors.messages.too_long', attribute: attribute, count: count)
    )
  end

  def then_I_should_see_a_validation_message(error)
    expect(editor).to have_content(
      I18n.t("activemodel.errors.models.service_slug.#{error}")
    )
  end

  def then_I_should_see_the_unique_validation_message(message)
    expect(editor).to have_content(message)
  end

  def form_name_field
    page.find(:css, 'input#service-service-name-field')
  end

  def form_url_field
    page.find(:css, 'input#service-service-slug-field')
  end
end
