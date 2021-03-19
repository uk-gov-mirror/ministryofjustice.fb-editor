require_relative '../spec_helper'

feature 'Edit single question page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'star-wars-question' }
  let(:question) do
    'Which program do Jedi use to open PDF files?'
  end
  let(:editable_options) do
    ['Adobe-wan Kenobi', 'PDFinn']
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'when editing text component' do
    given_I_have_a_single_question_page_with_text
    when_I_update_the_question_name
    and_I_return_to_flow_page
    then_I_should_see_my_changes_on_preview
  end

  scenario 'when editing textarea component' do
    given_I_have_a_single_question_page_with_textarea
    when_I_update_the_question_name
    and_I_return_to_flow_page
    then_I_should_see_my_changes_on_preview
  end

  scenario 'when editing number component' do
    given_I_have_a_single_question_page_with_number
    when_I_update_the_question_name
    and_I_return_to_flow_page
    then_I_should_see_my_changes_on_preview
  end

  scenario 'when editing date component' do
    given_I_have_a_single_question_page_with_date
    when_I_update_the_question_name
    and_I_return_to_flow_page
    then_I_should_see_my_changes_on_preview
  end

  scenario 'when editing radio component' do
    given_I_have_a_single_question_page_with_radio
    when_I_update_the_question_name
    and_I_update_the_options
    and_I_return_to_flow_page
    preview_form = then_I_should_see_my_changes_on_preview
    and_I_should_see_the_options_that_I_added(preview_form)
  end

  scenario 'when editing checkboxes component' do
    given_I_have_a_single_question_page_with_checkboxes
    when_I_update_the_question_name
    and_I_update_the_options
    and_I_return_to_flow_page
    preview_form = then_I_should_see_my_changes_on_preview
    and_I_should_see_the_options_that_I_added(preview_form)
  end

  def given_I_have_a_single_question_page_with_textarea
    given_I_add_a_single_question_page_with_text_area
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def given_I_have_a_single_question_page_with_number
    given_I_add_a_single_question_page_with_number
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def given_I_have_a_single_question_page_with_date
    given_I_add_a_single_question_page_with_date
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def given_I_have_a_single_question_page_with_checkboxes
    given_I_add_a_single_question_page_with_checkboxes
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def and_I_edit_the_question
    editor.question_heading.first.set(question)
  end

  def and_I_preview_the_form
    window_opened_by do
      editor.preview_form_button.click
    end
  end

  def and_I_go_to_the_page_that_I_edit(preview_form)
    within_window(preview_form) do
      page.click_button 'Start now'
    end
  end

  def when_I_update_the_question_name
    and_I_edit_the_question
    when_I_save_my_changes
  end

  def and_I_edit_the_options
    editor.editable_options.first.set(editable_options.first)
    editor.editable_options.last.set(editable_options.last)
  end

  def and_I_update_the_options
    and_I_edit_the_options
    when_I_save_my_changes
  end

  def then_I_should_see_my_changes_on_preview
    preview_form = and_I_preview_the_form

    and_I_go_to_the_page_that_I_edit(preview_form)
    then_I_should_see_my_changes_in_the_form(preview_form)

    preview_form
  end

  def then_I_should_see_my_changes_in_the_form(preview_form)
    within_window(preview_form) do
      expect(page.text).to include(question)
    end
  end

  def and_I_should_see_the_options_that_I_added(preview_form)
    within_window(preview_form) do
      editable_options.each do |option|
        expect(page.text).to include(option)
      end
    end
  end
end
