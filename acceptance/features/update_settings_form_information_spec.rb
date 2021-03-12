require_relative '../spec_helper'

feature 'Update settings form information' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:updated_service_name) { generate_service_name }
  let(:another_service_name) { generate_service_name }

  background do
    editor.load
    given_I_am_logged_in
    given_I_have_a_service
    and_I_go_to_update_the_form_information_in_settings
  end

  scenario 'current service name as input value' do
    then_I_should_see_the_current_service_name_in_the_input
  end

  scenario 'validates the service name' do
    given_I_update_a_service_with_empty_name
    when_I_update_the_service
    then_I_should_see_a_validation_message_for_required
  end

  scenario 'validates the service name min length' do
    given_I_update_a_service_with_one_character
    when_I_update_the_service
    then_I_should_see_a_validation_message_for_min_length
  end

  scenario 'validates the service name max length' do
    given_I_update_a_service_with_many_characters
    when_I_update_the_service
    then_I_should_see_a_validation_message_for_max_length
  end

  scenario 'updates the service in settings' do
    given_I_update_the_service_name
    then_I_should_see_the_new_service_name
  end

  scenario 'validates uniqueness of the service name' do
    given_I_have_another_service
    and_I_go_to_update_the_form_information_in_settings
    when_I_try_to_change_service_name_adding_an_existing_service_name
    then_I_should_see_the_unique_validation_message
  end

  def and_I_go_to_update_the_form_information_in_settings
    editor.load
    editor.edit_service_link(service_name).click
    editor.settings_link.click
    editor.form_information_link.click
  end

  def given_I_update_the_service_name
    editor.form_name_field.set(updated_service_name)
    editor.save_button.click
  end

  def given_I_update_a_service_with_empty_name
    editor.form_name_field.set('')
  end

  def given_I_update_a_service_with_one_character
    editor.form_name_field.set('C')
  end

  def given_I_update_a_service_with_many_characters
    editor.form_name_field.set('Stormtrooper Aim' * 100)
  end

  def when_I_update_the_service
    editor.save_button.click
  end

  def when_I_try_to_change_service_name_adding_an_existing_service_name
    editor.form_name_field.set(another_service_name)
    when_I_update_the_service
  end

  def then_I_should_see_the_current_service_name_in_the_input
    expect(editor.form_name_field.value).to eq(service_name)
  end

  def then_I_should_see_the_new_service_name
    expect(editor.service_name.text).to eq(updated_service_name)
  end

  def then_I_should_see_a_validation_message_for_required
    expect(editor.text).to include(
      "Your answer for ‘Form name’ can not be blank."
    )
  end

  def then_I_should_see_a_validation_message_for_min_length
    expect(editor.text).to include(
      "Your answer for ‘Form name’ is too short (3 characters at least)"
    )
  end

  def then_I_should_see_a_validation_message_for_max_length
    expect(editor.text).to include(
      "Your answer for ‘Form name’ is too long (128 characters at most)"
    )
  end

  def then_I_should_see_the_unique_validation_message
    expect(editor.text).to include(
      "Your answer for ‘Form name' is already used by another form. Please modify it."
    )
  end
end
