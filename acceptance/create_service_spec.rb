require_relative './spec_helper'

feature 'Create a service' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:another_service_name) { generate_service_name }

  background do
    editor.load
  end

  scenario 'validates the service name' do
    given_I_add_a_service_with_empty_name
    when_I_create_the_service
    then_I_should_see_a_validation_message_for_required
  end

  scenario 'validates the service name min length' do
    given_I_add_a_service_with_one_character
    when_I_create_the_service
    then_I_should_see_a_validation_message_for_min_length
  end

  scenario 'validates the service name max length' do
    given_I_add_a_service_with_many_characters
    when_I_create_the_service
    then_I_should_see_a_validation_message_for_max_length
  end

  scenario 'creates the service with a start page' do
    given_I_add_a_service
    when_I_create_the_service
    then_I_should_see_the_new_service_name
  end

  scenario 'validates uniqueness of the service name' do
    given_I_have_a_service
    when_I_try_to_create_a_service_with_the_same_name
    then_I_should_see_the_unique_validation_message
  end

  def given_I_add_a_service
    editor.name_field.set(service_name)
  end

  def given_I_add_a_service_with_empty_name
    editor.name_field.set('')
  end

  def given_I_add_a_service_with_one_character
    editor.name_field.set('M')
  end

  def given_I_add_a_service_with_many_characters
    editor.name_field.set('Stormtroopers' * 100)
  end

  def when_I_create_the_service
    editor.create_service_button.click
  end

  def when_I_try_to_create_a_service_with_the_same_name
    editor.load
    editor.name_field.set(another_service_name)
    editor.create_service_button.click
  end

  def then_I_should_see_the_new_service_name
    expect(editor.service_name.text).to eq(service_name)
  end

  def then_I_should_see_a_validation_message_for_required
    expect(editor.text).to include(
      "Your answer for ‘What is the name of this form?’ can not be blank."
    )
  end

  def then_I_should_see_a_validation_message_for_min_length
    expect(editor.text).to include(
      "Your answer for ‘What is the name of this form?’ is too short (3 characters at least)"
    )
  end

  def then_I_should_see_a_validation_message_for_max_length
    expect(editor.text).to include(
      "Your answer for ‘What is the name of this form?’ is too long (128 characters at most) "
    )
  end

  def then_I_should_see_the_unique_validation_message
    expect(editor.text).to include(
      "Your answer for ‘What is the name of this form?' is already used by another form. Please modify it."
    )
  end
end
