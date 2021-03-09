require_relative './spec_helper'

feature 'Update email settings in submission settings' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:updated_service_name) { generate_service_name }
  let(:another_service_name) { generate_service_name }

  background do
    editor.load
    given_I_have_a_service
    and_I_go_to_email_settings_in_submission_settings
  end

  scenario 'validation when ticked send by email on test' do
    given_that_I_ticked_the_send_by_email_on_test
    when_I_save_the_settings_on_test
    then_I_should_see_an_error_message_on_send_email_to_field
  end

  scenario 'save when ticked send by email on test' do
    given_that_I_ticked_the_send_by_email_on_test
    and_I_add_on_test_an_email_to_send
    when_I_save_the_settings_on_test
    then_I_should_see_my_email_to_send_to_on_test
    and_I_should_see_the_send_by_email_on_test_ticked
  end

  scenario 'save when unticked send by email on test' do
    given_that_I_unticked_the_send_by_email
    and_I_add_on_test_an_email_to_send
    when_I_save_the_settings_on_test
    then_I_should_see_my_email_to_send_to_on_test
    and_I_should_see_the_send_by_email_on_test_unticked
  end

  scenario 'save when unticked send by email and email to send on test is empty' do
    given_that_I_unticked_the_send_by_email
    and_email_to_send_to_on_test_is_empty
    when_I_save_the_settings_on_test
    then_I_should_see_empty_email_to_send_to_on_test
    and_I_should_see_the_send_by_email_on_test_unticked
  end

  scenario 'when adding an email subject on test' do
    and_I_click_configure_on_test
    and_I_add_a_email_subject_on_test
    when_I_save_the_settings_on_test
    then_I_should_see_the_email_subject_on_test
  end

  scenario 'when email subject on test is empty' do
    and_I_click_configure_on_test
    and_I_add_an_empty_email_subject_on_test
    when_I_save_the_settings_on_test
    then_I_should_see_the_email_subject_default
  end

  scenario 'validation when ticked send by email on live' do
    given_that_I_ticked_the_send_by_email_on_live
    when_I_save_the_settings_on_live
    then_I_should_see_an_error_message_on_send_email_to_field_on_live
  end

  scenario 'save when ticked send by email on live' do
    given_that_I_ticked_the_send_by_email_on_live
    and_I_add_on_live_an_email_to_send
    when_I_save_the_settings_on_live
    then_I_should_see_my_email_to_send_to_on_live
    and_I_should_see_the_send_by_email_on_live_ticked
  end

  scenario 'when adding an email subject on live' do
    and_I_click_configure_on_live
    and_I_add_a_email_subject_on_live
    when_I_save_the_settings_on_live
    then_I_should_see_the_email_subject_on_live
  end

  scenario 'when email subject on live is empty' do
    and_I_click_configure_on_live
    and_I_add_an_empty_email_subject_on_live
    when_I_save_the_settings_on_live
    then_I_should_see_the_email_subject_default
  end

  scenario 'when adding an email body on live' do
    and_I_click_configure_on_live
    and_I_add_an_email_body_on_live
    when_I_save_the_settings_on_live
    then_I_should_see_the_email_body_on_live
  end

  scenario 'when email body on live is empty' do
    and_I_click_configure_on_live
    and_I_add_an_empty_email_body_on_live
    when_I_save_the_settings_on_live
    then_I_should_see_the_email_body_default
  end

  scenario 'when adding an email pdf heading on live' do
    and_I_click_configure_on_live
    and_I_add_an_email_pdf_heading_on_live
    when_I_save_the_settings_on_live
    then_I_should_see_the_email_pdf_heading_on_live
  end

  scenario 'when email pdf heading on live is empty' do
    and_I_click_configure_on_live
    and_I_add_an_empty_email_pdf_heading_on_live
    when_I_save_the_settings_on_live
    then_I_should_see_the_email_pdf_heading_default_on_live
  end

  scenario 'when adding an email pdf subheading on live' do
    and_I_click_configure_on_live
    and_I_add_an_email_pdf_subheading_on_live
    when_I_save_the_settings_on_live
    then_I_should_see_the_email_pdf_subheading_on_live
  end

  scenario 'when email pdf subheading on live is empty' do
    and_I_click_configure_on_live
    and_I_add_an_empty_email_pdf_subheading_on_live
    when_I_save_the_settings_on_live
    then_I_should_see_the_email_pdf_subheading_is_empty_on_live
  end

  def and_I_go_to_email_settings_in_submission_settings
    editor.load
    editor.edit_service_link(service_name).click
    editor.settings_link.click
    editor.submission_settings_link.click
    editor.send_by_email_link.click
  end

  def given_that_I_ticked_the_send_by_email_on_test
    editor.email_submission_test.send_by_email_on_test.check
    and_I_click_configure_on_test
  end

  def given_that_I_ticked_the_send_by_email_on_live
    editor.email_submission_live.send_by_email_on_live.check
    and_I_click_configure_on_live
  end

  def given_that_I_unticked_the_send_by_email
    editor.email_submission_test.send_by_email_on_test.uncheck
    and_I_click_configure_on_test
  end

  def and_I_click_configure_on_test
    editor.email_submission_test.configure_link_on_test.click
  end

  def and_I_click_configure_on_live
    editor.email_submission_live.configure_link_on_live.click
  end

  def and_I_add_on_test_an_email_to_send
    editor.email_submission_test.send_email_to_field.set('boromir@gondor.gov.uk')
  end

  def and_I_add_on_live_an_email_to_send
    editor.email_submission_live.send_email_to_field.set('frodo@shire.gov.uk')
  end

  def and_email_to_send_to_on_test_is_empty
    editor.email_submission_test.send_email_to_field.set('')
  end

  def and_I_add_a_email_subject_on_test
    editor.email_submission_test.email_subject_field.set('Hello')
  end

  def and_I_add_a_email_subject_on_live
    editor.email_submission_live.email_subject_field.set('This is Live!')
  end

  def and_I_add_an_empty_email_subject_on_test
    editor.email_submission_test.email_subject_field.set('')
  end

  def and_I_add_an_empty_email_subject_on_live
    editor.email_submission_live.email_subject_field.set('')
  end

  def and_I_add_an_empty_email_body_on_live
    editor.email_submission_live.email_body_field.set('')
  end

  def and_I_add_an_empty_email_pdf_heading_on_live
    editor.email_submission_live.email_pdf_heading_field.set('')
  end

  def and_I_add_an_empty_email_pdf_subheading_on_live
    editor.email_submission_live.email_pdf_subheading_field.set('')
  end

  def and_I_add_an_email_body_on_live
    editor.email_submission_live.email_body_field.set(
      'So we\'re all gathered here today to celebrate the reconnection of our phones, and this bounteous Wi-Fi!'
    )
  end

  def and_I_add_an_email_pdf_heading_on_live
    editor.email_submission_live.email_pdf_heading_field.set('PDF Heading')
  end

  def and_I_add_an_email_pdf_subheading_on_live
    editor.email_submission_live.email_pdf_subheading_field.set('PDF Subheading')
  end

  def when_I_save_the_settings_on_test
    editor.email_submission_test.save_button.click
  end

  def when_I_save_the_settings_on_live
    editor.email_submission_live.save_button.click
  end

  def then_I_should_see_an_error_message_on_send_email_to_field
    and_I_click_configure_on_test
    expect(
      editor.email_submission_test.error_messages.map(&:text)
    ).to match_array([
      "Your answer for ‘Send email to’ can not be blank."
    ])
  end

  def then_I_should_see_an_error_message_on_send_email_to_field_on_live
    and_I_click_configure_on_live
    expect(
      editor.email_submission_live.error_messages.map(&:text)
    ).to match_array([
      "Your answer for ‘Send email to’ can not be blank."
    ])
  end

  def then_I_should_see_my_email_to_send_to_on_test
    and_I_go_to_email_settings_in_submission_settings
    and_I_click_configure_on_test
    expect(editor.email_submission_test.send_email_to_field.value).to eq(
      'boromir@gondor.gov.uk'
    )
  end

  def then_I_should_see_my_email_to_send_to_on_live
    and_I_go_to_email_settings_in_submission_settings
    and_I_click_configure_on_live
    expect(editor.email_submission_live.send_email_to_field.value).to eq(
      'frodo@shire.gov.uk'
    )
  end

  def then_I_should_see_the_email_body_on_live
    and_I_go_to_email_settings_in_submission_settings
    and_I_click_configure_on_live
    expect(editor.email_submission_live.email_body_field.value).to eq(
      'So we\'re all gathered here today to celebrate the reconnection of our phones, and this bounteous Wi-Fi!'
    )
  end

  def then_I_should_see_empty_email_to_send_to_on_test
    and_I_go_to_email_settings_in_submission_settings
    and_I_click_configure_on_test
    expect(editor.email_submission_test.send_email_to_field.value).to eq('')
  end

  def then_I_should_see_the_email_subject_on_test
    and_I_go_to_email_settings_in_submission_settings
    and_I_click_configure_on_test
    expect(editor.email_submission_test.email_subject_field.value).to eq('Hello')
  end

  def then_I_should_see_the_email_subject_on_live
    and_I_go_to_email_settings_in_submission_settings
    and_I_click_configure_on_live
    expect(editor.email_submission_live.email_subject_field.value).to eq('This is Live!')
  end

  def then_I_should_see_the_email_pdf_heading_on_live
    and_I_go_to_email_settings_in_submission_settings
    and_I_click_configure_on_live
    expect(editor.email_submission_live.email_pdf_heading_field.value).to eq('PDF Heading')
  end

  def then_I_should_see_the_email_pdf_subheading_on_live
    and_I_go_to_email_settings_in_submission_settings
    and_I_click_configure_on_live
    expect(editor.email_submission_live.email_pdf_subheading_field.value).to eq('PDF Subheading')
  end

  def then_I_should_see_the_email_subject_default
    and_I_click_configure_on_test
    expect(editor.email_submission_test.email_subject_field.value).to include('Submission from ')
  end

  def then_I_should_see_the_email_body_default
    and_I_click_configure_on_live
    expect(editor.email_submission_live.email_body_field.value).to include('Please find attached a submission sent from ')
  end

  def then_I_should_see_the_email_pdf_heading_default_on_live
    and_I_click_configure_on_live
    expect(editor.email_submission_live.email_pdf_heading_field.value).to include('Submission for ')
  end

  def then_I_should_see_the_email_pdf_subheading_is_empty_on_live
    and_I_go_to_email_settings_in_submission_settings
    and_I_click_configure_on_live
    expect(editor.email_submission_live.email_pdf_subheading_field.value).to eq('')
  end

  def and_I_should_see_the_send_by_email_on_test_ticked
    and_I_go_to_email_settings_in_submission_settings
    expect(editor.email_submission_test.send_by_email_on_test).to be_checked
  end

  def and_I_should_see_the_send_by_email_on_live_ticked
    and_I_go_to_email_settings_in_submission_settings
    expect(editor.email_submission_live.send_by_email_on_live).to be_checked
  end

  def and_I_should_see_the_send_by_email_on_test_unticked
    and_I_go_to_email_settings_in_submission_settings
    expect(editor.email_submission_test.send_by_email_on_test).to_not be_checked
  end
end
