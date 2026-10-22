require_relative '../spec_helper'

feature 'Create page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'phasma' }
  let(:start_page_title) { 'Service name goes here' }
  let(:checkanswers_link_text) { I18n.t('actions.add_check_answers') }
  let(:checkanswers_title) { 'Check your answers' }
  let(:confirmation_link_text) { I18n.t('actions.add_confirmation')  }
  let(:confirmation_title) { 'Application complete' }

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

  scenario 'creating a single question page with email' do
    given_I_add_a_single_question_page_with_email
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_single_question_email_page
  end

  scenario 'creating a single question page with autocomplete' do
    given_I_add_a_single_question_page_with_autocomplete
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_single_question_autocomplete_page
  end

  scenario 'creating a single page with address' do
    given_I_add_a_single_question_page_with_address
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_single_question_address_page
  end

  scenario 'creating multiple question page' do
    given_I_add_a_multiple_question_page
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_multiple_question_page
  end

  scenario 'creating check answers page' do
    then_I_should_see_default_service_pages
    then_I_should_not_be_able_to_add_page(start_page_title, checkanswers_link_text)
    and_I_delete_cya_page
    then_I_should_see_delete_warning_cya
    then_I_should_be_able_to_add_page(start_page_title, checkanswers_link_text)
    given_I_add_a_check_answers_page('Service name goes here')
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_check_answers_page
    and_I_return_to_flow_page
    then_I_should_not_be_able_to_add_page(start_page_title, checkanswers_link_text)
  end

  scenario 'creating confirmation page' do
    then_I_should_see_default_service_pages
    then_I_should_not_be_able_to_add_page(start_page_title, confirmation_link_text)
    when_I_delete_confirmation_page
    then_I_should_see_delete_warning_confirmation
    then_I_should_be_able_to_add_page(checkanswers_title, confirmation_link_text)
    given_I_add_a_confirmation_page
    and_I_add_a_page_url
    when_I_add_the_page
    then_I_should_see_the_edit_confirmation_page
    and_I_return_to_flow_page
    then_I_should_not_be_able_to_add_page(start_page_title, confirmation_link_text)
  end

  context 'existing urls' do
    let(:error_message) { 'You already have a page with that name' }

    scenario 'attempt to add a page with an existing url in the service flow' do
      given_I_have_a_single_question_page_with_text
      # Ensure editor page is loaded and interactive before proceeding
      expect(page).to have_css('#main-content', visible: true)
      add_existing_url
    end

    scenario 'attempt to add a page with an existing url' do
      # Wait for metadata to be present before collecting URLs
      expect(page).to have_css('#main-content', visible: true)
      all_page_urls.each { |url| add_existing_url(url) }
    end
  end

  context 'reserved urls' do
    let(:error_message) { 'That name is used for something else' }

    scenario 'attempt to add a page with a reserved url' do
      expect(page).to have_css('#main-content', visible: true)
      reserved_urls.each { |url| add_existing_url(url) }
    end
  end

  def then_I_should_see_a_validation_error_message_that_page_url_exists
    expect(editor).to have_content(error_message)
  end

  def then_I_should_see_the_edit_single_question_text_page
    and_I_should_be_on_the_edit_page
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

  def then_I_should_see_the_edit_single_question_email_page
    and_I_should_see_default_values_for_email_created
    and_I_should_see_the_save_button_visible
    and_I_should_see_the_save_button_disabled
    expect(editor.find('input[type="email"]')).to be_visible
  end

  def then_I_should_see_the_edit_single_question_autocomplete_page
    and_I_should_see_default_values_created
    and_I_should_see_the_save_button_visible
    and_I_should_see_default_upload_options_warning
    and_I_should_see_the_save_button_disabled
    expect(page).to have_css('.govuk-select', visible: true)
  end

  def then_I_should_see_the_edit_single_question_address_page
    and_I_should_be_on_the_address_edit_page
    and_I_should_see_default_address_created
  end

  def and_I_should_be_on_the_edit_page
    and_I_should_see_default_values_created
    and_I_should_see_the_save_button_visible
    and_I_should_see_the_save_button_disabled
  end

  def and_I_should_be_on_the_address_edit_page
    and_I_should_see_default_values_created('Address question')
    and_I_should_see_the_save_button_visible
    and_I_should_see_the_save_button_disabled
  end

  def and_I_should_see_three_inputs_for_day_month_and_year
    expect(page).to have_field('Day',   type: 'text')
    expect(page).to have_field('Month', type: 'text')
    expect(page).to have_field('Year',  type: 'text')
  end

  def and_I_should_see_default_values_created(legend_or_label = 'Question')
    expect(editor).to have_content(legend_or_label)
    expect(editor).to have_content('[Optional hint text]')
  end

  def and_I_should_see_default_values_for_email_created
    expect(editor).to have_content('Email address question')
    expect(editor).to have_content('[Optional hint text]')
  end
  def and_I_should_see_default_radio_options_created
    expect(
      editor.radio_options.map { |option| option[:value] }
    ).to match_array(%w[Option Option])
  end

  def and_I_should_see_default_checkboxes_created
    expect(
      editor.checkboxes_options.map { |option| option[:value] }
    ).to match_array(%w[Option Option])
  end

  def and_I_should_see_default_address_created
    expect(editor.all('input[type="text"]').size).to be(6)
    expect(editor.all('input[type="text"]').last.value).to eq('United Kingdom')
    # or, if the field may include trailing spaces or different capitalization:
    # expect(editor.all('input[type="text"]').last.value).to include('United Kingdom')
  end

  def then_I_should_see_the_edit_multiple_question_page
    expect(editor).to have_content('Title')
    and_I_should_see_the_save_button_visible
    and_I_should_see_the_save_button_disabled
  end

  def then_I_should_see_the_edit_check_answers_page
    expect(editor).to have_content('Check your answers')
    expect(editor).to have_content(
      'By submitting this application you confirm that, to the best of your knowledge, the details you are providing are correct'
    )
    and_I_should_see_the_save_button_visible
    and_I_should_see_the_save_button_disabled
  end

  def then_I_should_see_the_edit_confirmation_page
    expect(editor).to have_content('Application complete')
    and_I_should_see_the_save_button_visible
    and_I_should_see_the_save_button_disabled
  end

  def and_I_should_see_the_save_button_visible
    expect(editor.save_page_button).to be_visible
  end

  def and_I_should_see_the_save_button_disabled
    expect(editor.save_page_button[:'aria-disabled']).to eq("true")
  end

  def given_I_add_a_single_question_page_with_text_area
    given_I_want_to_add_a_single_question_page
    editor.add_component(I18n.t('components.list.textarea')).click
  end

  def given_I_add_a_single_question_page_with_number
    given_I_want_to_add_a_single_question_page
    editor.add_component(I18n.t('components.list.number')).click
  end

  def given_I_add_a_single_question_page_with_date
    given_I_want_to_add_a_single_question_page
    editor.add_component(I18n.t('components.list.date')).click
  end

  def add_existing_url(url = nil)
    and_I_edit_the_service
    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url(url)
    when_I_add_the_page
    then_I_should_see_a_validation_error_message_that_page_url_exists
  end

  def all_page_urls
    page_urls = service.metadata['pages'].map { |page| page['url'] }
    standalone_urls = service.metadata['standalone_pages'].map { |page| page['url'] }
  end

  def reserved_urls
    MetadataUrlValidator::RESERVED
  end
end
