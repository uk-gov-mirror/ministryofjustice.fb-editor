require_relative '../spec_helper'

feature 'Edit multiple questions page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'hakuna-matata' }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'adding components' do
    given_I_have_a_multiple_questions_page
    and_I_add_a_text_component
    and_I_add_a_textarea_component
    and_I_add_a_radio_component
    and_I_add_a_checkbox_component
    and_I_update_the_components
    when_I_save_my_changes
    and_I_return_to_flow_page
    and_I_edit_the_page(url: page_url)
    then_I_should_see_all_components
  end

  def given_I_have_a_multiple_questions_page
    given_I_add_a_multiple_question_page
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def and_I_add_a_text_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_text.click
  end

  def and_I_add_a_component
    editor.add_a_component_button.click
  end

  def and_I_add_a_question
    editor.question_component.hover
  end

  def and_I_add_a_textarea_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_text_area.click
  end

  def and_I_add_a_radio_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_radio.click
  end

  def and_I_add_a_checkbox_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_checkboxes.click
  end

  def and_I_update_the_components
  end

  def then_I_should_see_all_components
  end
end
