require_relative '../spec_helper'

feature 'Edit single question autocomplete page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'Countries' }
  let(:pre_edit_title) { 'Countries Question' }
  let(:question) do
    'What is your favourite holiday destination?'
  end
  let(:section_heading) { 'I open at the close' }
  let(:default_section_heading) { I18n.t('default_text.section_heading') }
  let(:upload_success) { I18n.t('dialogs.autocomplete.success') }
  let(:upload_button) { I18n.t('dialogs.autocomplete.button') }
  let(:upload_modal_warning) { I18n.t('dialogs.autocomplete.modal_warning') }
  let(:valid_csv) { './spec/fixtures/autocomplete/special_characters.csv' }
  let(:valid_csv_one_column) { './spec/fixtures/autocomplete/valid_one_column.csv' }
  let(:autocomplete_option) { 'Congo, Democratic Republic of' }
  let(:invalid_csv) { './spec/fixtures/autocomplete/invalid.csv' }
  let(:incorrect_format) { I18n.t('activemodel.errors.models.autocomplete_items.invalid_headings') }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'autocomplete_page_fixture')
  end

  scenario 'when editing the autocomplete component' do
    and_I_edit_the_page(url: pre_edit_title)
    and_I_have_optional_section_heading_text
    when_I_update_the_question_name
    when_I_update_the_optional_section_heading
    when_I_delete_the_optional_section_heading_text
    and_I_return_to_flow_page
    then_I_should_see_my_changes_on_preview(question)
  end

  scenario 'when uploading and overwriting csv files' do
    and_I_edit_the_page(url: pre_edit_title)
    and_I_should_see_default_upload_options_warning
    when_I_click_autocomplete_options_in_three_dots_menu
    then_I_should_see_upload_options_modal
    when_I_upload_a_csv_file(valid_csv_one_column)
    then_I_should_see_confirmation_message
    when_I_click_autocomplete_options_in_three_dots_menu
    then_I_should_see_upload_options_modal
    then_I_should_see_overwrite_options_warning
    when_I_upload_a_csv_file(valid_csv)
    then_I_should_see_confirmation_message
    and_I_return_to_flow_page
    then_I_should_see_my_changes_on_preview(autocomplete_option)
  end

  scenario 'when uploading an invalid csv file' do
    and_I_edit_the_page(url: pre_edit_title)
    and_I_should_see_default_upload_options_warning
    when_I_click_autocomplete_options_in_three_dots_menu
    then_I_should_see_upload_options_modal
    when_I_upload_a_csv_file(invalid_csv)
    then_I_should_see_an_error_message(incorrect_format)
  end

  def then_I_should_see_my_changes_on_preview(change)
    preview_form = and_I_preview_the_form

    and_I_go_to_the_page_that_I_edit(preview_form)
    then_I_should_see_my_changes_in_the_form(preview_form, change)

    preview_form
  end

  def and_I_go_to_the_page_that_I_edit(preview_form)
    within_window(preview_form) do
      page.click_button 'Start now'
    end
  end

  def then_I_should_see_my_changes_in_the_form(preview_form, content)
    within_window(preview_form) do
      page.find('.autocomplete__input').click
      sleep 2
      expect(page).to have_text(:all, content)
    end
  end

  def and_I_have_optional_section_heading_text
    editor.service_name.click
    expect(page).to have_content(I18n.t('default_text.section_heading'))
  end

  def when_I_update_the_question_name
    and_I_edit_the_question
    when_I_save_my_changes
  end

  def when_I_update_the_optional_section_heading
    and_I_edit_the_optional_section_heading
    when_I_save_my_changes
    then_I_should_see_my_updated_section_heading
  end

  def then_I_should_see_my_updated_section_heading
    expect(editor).to have_content(section_heading)
  end

  def when_I_delete_the_optional_section_heading_text
    editor.section_heading_hint.set(' ')
    when_I_save_my_changes
    then_I_should_see_the_default_section_heading
  end

  def then_I_should_see_the_default_section_heading
    editor.service_name.click
    expect(editor.section_heading_hint).to have_text(default_section_heading, exact: true)
  end

  def and_I_edit_the_question
    editor.question_heading.first.set(question)
  end

  def and_I_edit_the_optional_section_heading
    page.first('.fb-section_heading').set(section_heading)
  end

  def then_I_should_see_overwrite_options_warning
    expect(page).to have_content(upload_modal_warning)
  end

  def then_I_should_see_confirmation_message
    # The upload box closes once the upload has finished. Checking the message
    # alone is not enough: the first upload's message is still on the page.
    expect(page).to have_no_css('.ui-dialog')
    expect(page).to have_content(upload_success)
  end

  def then_I_should_see_an_error_message(error_message)
    expect(page).to have_content(error_message)
  end
end
