require_relative '../spec_helper'

feature 'Create page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'creating a single question page with text' do
    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_single_question_text_page
  end

  scenario 'creating a single question page with textarea' do
    given_I_add_a_single_question_page_with_text_area
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_single_question_text_area_page
  end

  scenario 'creating a single question page with number' do
    given_I_add_a_single_question_page_with_number
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_single_question_number_page
  end

  scenario 'creating a single question page with date' do
    given_I_add_a_single_question_page_with_date
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_single_question_date_page
  end

  scenario 'creating a single question page with radio' do
    given_I_add_a_single_question_page_with_radio
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_single_question_radio_page
  end

  scenario 'creating a single question page with checkboxes' do
    given_I_add_a_single_question_page_with_checkboxes
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_single_question_checkboxes_page
  end

  scenario 'creating multiple question page' do
    given_I_add_a_multiple_question_page
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_multiple_question_page
  end

  scenario 'creating a check answers page' do
    given_I_add_a_check_answers_page
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_check_answers_page
  end

  scenario 'creating confirmation page' do
    given_I_add_a_confirmation_page
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_confirmation_page
  end

  scenario 'attempt to add a page with an existing url' do
    given_I_have_a_single_question_page_with_text
    and_I_edit_the_service
    given_I_add_a_single_question_page_with_text
    and_I_add_an_existing_page_url
    when_I_add_the_page
    then_I_should_see_a_validation_error_message_that_page_url_exists
  end

  def given_I_have_a_single_question_page_with_text
    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def given_I_add_a_single_question_page_with_text
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_text.click
  end

  def given_I_add_a_single_question_page_with_text_area
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_text_area.click
  end

  def given_I_add_a_single_question_page_with_number
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_number.click
  end

  def given_I_add_a_single_question_page_with_date
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_date.click
  end

  def given_I_add_a_single_question_page_with_radio
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_radio.click
  end

  def given_I_add_a_single_question_page_with_checkboxes
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_checkboxes.click
  end

  def given_I_add_a_check_answers_page
    given_I_want_to_add_a_page
    editor.add_check_answers.click
  end

  def given_I_add_a_multiple_question_page
    given_I_want_to_add_a_page
    editor.add_multiple_question.click
  end

  def given_I_add_a_confirmation_page
    given_I_want_to_add_a_page
    editor.add_confirmation.click
  end

  def given_I_want_to_add_a_single_question_page
    given_I_want_to_add_a_page
    editor.add_single_question.hover
  end

  def given_I_want_to_add_a_page
    editor.add_page.click
  end

  def and_I_edit_the_service
    visit '/services'
    editor.edit_service_link(service_name).click
  end

  def and_I_add_a_page_url
    editor.page_url_field.set('phasma')
  end

  def and_I_add_an_existing_page_url
    and_I_add_a_page_url
  end

  def when_I_add_the_page
    editor.add_page_submit_button.last.click
  end

  def then_I_should_see_a_validation_error_message_that_page_url_exists
    expect(editor.text).to include(
      "Your answer for ‘The page’s relative url - it must not contain any spaces' is already used by another page. Please modify it."
    )
  end

  def then_I_should_see_the_edit_single_question_text_page
    and_I_should_be_on_the_edit_page
    expect(editor.find('input[type="text"]')).to be_visible
  end

  def then_I_should_see_the_edit_single_question_text_area_page
    and_I_should_be_on_the_edit_page
    expect(editor.find('textarea')).to be_visible
  end

  def then_I_should_see_the_edit_single_question_number_page
    # number component is similar to the text component
    then_I_should_see_the_edit_single_question_text_page
  end

  def then_I_should_see_the_edit_single_question_date_page
    and_I_should_be_on_the_edit_page
    and_I_should_see_three_inputs_for_day_month_and_year
  end

  def then_I_should_see_the_edit_single_question_radio_page
    and_I_should_be_on_the_edit_page
    and_I_should_see_default_radio_options_created
  end

  def then_I_should_see_the_edit_single_question_checkboxes_page
    and_I_should_be_on_the_edit_page
    and_I_should_see_default_checkboxes_created
  end

  def and_I_should_be_on_the_edit_page
    and_I_should_see_default_values_created
    and_I_should_see_the_save_button_visible
    and_I_should_see_the_save_button_disabled
  end

  def and_I_should_see_three_inputs_for_day_month_and_year
    expect(editor.all('input[type="text"]').size).to be(3)
  end

  def and_I_should_see_default_values_created
    expect(editor.text).to include('Question')
    expect(editor.text).to include('[Optional hint text]')
  end

  def and_I_should_see_default_radio_options_created
    expect(
      editor.radio_options.map { |option| option[:value] }
    ).to match_array(['Option', 'Option'])
  end

  def and_I_should_see_default_checkboxes_created
    expect(
      editor.checkboxes_options.map { |option| option[:value] }
    ).to match_array(['Option', 'Option'])
  end

  def then_I_should_see_the_edit_multiple_question_page
    expect(editor.text).to include('Title')
    and_I_should_see_the_save_button_visible
    and_I_should_see_the_save_button_disabled
  end

  def then_I_should_see_the_edit_check_answers_page
    expect(editor.text).to include('Check your answers')
    expect(editor.text).to include(
      'By submitting this application you confirm that, to the best of your knowledge, the details you are providing are correct'
    )
    and_I_should_see_the_save_button_visible
    and_I_should_see_the_save_button_disabled
  end

  def then_I_should_see_the_edit_confirmation_page
    expect(editor.text).to include('Application complete')
    and_I_should_see_the_save_button_visible
    and_I_should_see_the_save_button_disabled
  end

  def and_I_should_see_the_save_button_visible
    expect(editor.save_page_button).to be_visible
  end

  def and_I_should_see_the_save_button_disabled
    expect(editor.save_page_button).to be_disabled
  end
end
