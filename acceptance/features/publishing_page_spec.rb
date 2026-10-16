# coding: utf-8
require_relative '../spec_helper'

feature 'Publishing' do
  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: fixture_name)
  end
  let(:fixture_name) { 'default_new_service_fixture' }
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'palpatine' }
  let(:modal_description) { I18n.t('activemodel.attributes.publish_service_creation.description') }
  let(:allow_anyone_text) { I18n.t('publish.dialog.option_1') }
  let(:username_and_password_text) { I18n.t('publish.dialog.option_2') }
  let(:username_and_password_errors) do
    [
      I18n.t('activemodel.errors.models.publish_service_creation.username_too_short'),
      I18n.t('activemodel.errors.models.publish_service_creation.password_too_short'),
    ]
  end
  let(:valid_email) { 'station-master-tama@justice.gov.uk' }

  shared_examples 'a publishing page environment' do
    let(:exit_url) { 'exit' }

    let(:button_class) { '.govuk-button.fb-govuk-button.DialogActivator' }
    let(:autocomplete_warning_message) { I18n.t("publish.autocomplete_items.#{environment}.message", title: 'Question') }
    let(:upload_button) { I18n.t('dialogs.autocomplete.button') }
    let(:valid_csv_one_column) { './spec/fixtures/autocomplete/valid_one_column.csv' }

    scenario 'service email output warning message and submission pages present' do
      when_I_visit_the_publishing_page

      and_I_click_the_environment_tab
      then_I_should_see_the_default_no_service_output_warning_message
      then_the_publish_button_should_be_enabled

      then_I_click_the_collecting_information_by_email_link
      then_I_should_be_on_collecting_information_by_email_page
      when_I_enable_the_submission_settings

      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_not_see_the_default_no_service_output_warning_message
      then_I_should_not_see_warning_both_text
      then_I_should_not_see_warning_cya_text
      then_I_should_not_see_warning_confirmation_text
    end

    scenario 'service email output warning message confirmation email and submission pages present' do
      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab

      then_I_should_see_the_default_no_service_output_warning_message
      then_the_publish_button_should_be_enabled

      and_I_add_an_email_question
      then_I_enable_confirmation_email

      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_see_the_confirmation_email_no_service_output_warning_message

      then_I_click_the_collecting_information_by_email_link
      then_I_should_be_on_collecting_information_by_email_page
      when_I_enable_the_submission_settings

      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_not_see_the_default_no_service_output_warning_message
      then_I_should_not_see_the_confirmation_email_no_service_output_warning_message

      then_I_should_not_see_warning_both_text
      then_I_should_not_see_warning_cya_text
      then_I_should_not_see_warning_confirmation_text
    end

    scenario 'when visiting the publishing page without submitting pages present' do
      given_I_have_a_single_question_page_with_upload
      and_I_return_to_flow_page
      and_I_delete_cya_page
      then_I_should_see_delete_warning_cya

      when_I_enable_the_submission_settings
      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_see_the_submission_warning_message
      then_I_should_not_see_warning_both_text
      then_I_should_not_see_warning_confirmation_text
      then_I_should_see_warning_cya_text

      and_I_return_to_flow_page
      given_I_add_an_exit_page
      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_see_the_submission_warning_message
      then_I_should_see_warning_both_text
      then_I_should_not_see_warning_cya_text
      then_I_should_not_see_warning_confirmation_text
    end

    scenario 'when visiting the publishing page without confirmation page present' do
      given_I_have_a_single_question_page_with_upload
      and_I_return_to_flow_page
      when_I_delete_confirmation_page

      when_I_enable_the_submission_settings
      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_not_see_warning_both_text
      then_I_should_not_see_warning_cya_text
      then_I_should_see_warning_confirmation_text
    end

    scenario 'autocomplete item warning messages' do
      given_I_add_a_single_question_page_with_autocomplete
      and_I_add_a_page_url
      when_I_add_the_page
      and_I_return_to_flow_page

      when_I_enable_the_submission_settings
      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_see_autocomplete_warnings
      then_I_should_see_the_publish_button

      and_I_return_to_flow_page
      and_I_edit_the_page(url: 'Question')
      when_I_click_autocomplete_options_in_three_dots_menu
      then_I_should_see_upload_options_modal
      when_I_upload_a_csv_file(valid_csv_one_column)

      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_not_see_autocomplete_warnings
      then_the_publish_button_should_be_enabled
    end
  end

  context 'when dev environment' do
    let(:environment) { 'dev' }
    let(:publish_button) { I18n.t('publish.dev.button') }
    let(:button_disabled) { '' } # aria-disabled is not set when button is enabled
    let(:warning_both){ 'it is missing a check answers page and confirmation page' }
    let(:warning_cya){ 'it is missing a check answers page' }
    let(:warning_confirmation){ 'it is missing a confirmation page'}

    it_behaves_like 'a publishing page environment'
  end

  context 'when production environment' do
    let(:environment) { 'production' }
    let(:publish_button) { I18n.t('publish.production.button') }
    let(:button_disabled) { 'true' }
    let(:warning_both){ 'add a check answers page and confirmation page' }
    let(:warning_cya){ 'add a check answers page' }
    let(:warning_confirmation){ 'add a confirmation page'}

    context 'when I have published before' do
      it_behaves_like 'a publishing page environment'
    end
  end

  scenario 'when username and password is too short' do
    # We are unable to test the Production environment as we cannot
    # validate the 'from' address email, which in turn blocks a user
    # from clicking the 'Publish to Live' button
    when_I_visit_the_publishing_page
    and_I_want_to_publish('Test')
    then_I_should_see_publish_to_test_modal

    then_username_and_password_should_be_the_default('dev')
    when_I_enter_invalid_username_and_password('dev', 'Test')
    then_I_should_see_username_and_password_error

    and_I_cancel
  end

  context 'autocomplete warning in Live' do
    let(:fixture_name) { 'autocomplete_page_fixture' }
    let(:environment) { 'production' }
    let(:button_disabled) { 'true' }
    let(:autocomplete_warning_message) do
      I18n.t("publish.autocomplete_items.#{environment}.message", title: 'Countries Question' )
    end

    scenario 'unconnected autocomplete page does not block Live publishing' do
      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_see_autocomplete_warnings
      then_I_should_see_the_publish_button

      and_I_return_to_flow_page
      given_I_want_to_change_destination_of_a_page('Service name goes here')
      when_I_change_destination_to_page('Check your answers')

      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_not_see_autocomplete_warnings
      then_the_publish_button_should_be_enabled
    end
  end
end

feature 'First publish for approval' do
  before do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name, fixture: fixture_name)
  end
  let(:fixture_name) { 'default_new_service_fixture' }
  let(:editor) { EditorApp.new }
  let(:service_name) { "no_approval-#{generate_service_name}" }
  let(:page_url) { 'palpatine' }
  let(:modal_description) { I18n.t('activemodel.attributes.publish_service_creation.description') }
  let(:allow_anyone_text) { I18n.t('publish.dialog.option_1') }
  let(:username_and_password_text) { I18n.t('publish.dialog.option_2') }
  let(:username_and_password_errors) do
    [
      I18n.t('activemodel.errors.models.publish_service_creation.username_too_short'),
      I18n.t('activemodel.errors.models.publish_service_creation.password_too_short'),
    ]
  end
  let(:valid_email) { 'station-master-tama@justice.gov.uk' }
  let(:environment) { 'production' }
  let(:warning_both){ 'check answers page and confirmation' }
  let(:warning_cya){ 'add a check answers page' }
  let(:warning_confirmation){ 'add a confirmation page'}
  let(:exit_url) { 'exit' }

  context 'when never published before ' do
    scenario 'resolve email warnings' do
      when_I_visit_the_publishing_page

      and_I_click_the_environment_tab
      then_I_should_see_the_default_no_service_output_warning_message

      then_I_click_the_collecting_information_by_email_link
      then_I_should_be_on_collecting_information_by_email_page
      when_I_enable_the_submission_settings

      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_not_see_the_default_no_service_output_warning_message
      then_I_should_not_see_warning_both_text
      then_I_should_not_see_warning_cya_text
      then_I_should_not_see_warning_confirmation_text
    end

    scenario 'resolve publishing warnings' do
      given_I_have_a_single_question_page_with_upload
      and_I_return_to_flow_page
      and_I_delete_cya_page
      then_I_should_see_delete_warning_cya

      when_I_enable_the_submission_settings
      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_see_the_submission_warning_message
      then_I_should_not_see_warning_both_text
      then_I_should_not_see_warning_confirmation_text
      then_I_should_see_warning_cya_text

      and_I_return_to_flow_page
      given_I_add_an_exit_page
      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_see_the_submission_warning_message
      then_I_should_see_warning_both_text
      then_I_should_not_see_warning_cya_text
      then_I_should_not_see_warning_confirmation_text
    end

    scenario 'accept the declarations' do
      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_see_the_declarations_checkboxes
      then_I_click_request_a_final_check
      then_I_should_see_the_declarations_error
      then_I_accept_the_declarations_with_error_summary
      then_I_click_request_a_final_check
      then_I_should_see_the_confirmation
      and_I_return_to_flow_page
      when_I_visit_the_publishing_page
      and_I_click_the_environment_tab
      then_I_should_see_the_confirmation
    end
  end
end

  def and_I_click_the_environment_tab
    sleep 0.5
    if environment == 'dev'
      editor.dev_tab.click
    else
      editor.production_tab.click
    end
  end

  def then_I_should_see_the_declarations_checkboxes
    expect(page.text).to include( I18n.t('publish.declarations.one_link_text'))
    expect(page.text).to include( I18n.t('publish.declarations.two_link_text'))
    expect(page.text).to include( I18n.t('publish.declarations.three_link_text'))
    expect(page.text).to include( I18n.t('publish.declarations.four_link_text'))
    expect(page.text).to include( I18n.t('publish.declarations.five_link_text'))
    expect(page.text).to include( I18n.t('publish.declarations.six_link_text'))
  end

  def then_I_click_request_a_final_check
    editor.publish_for_review.click
  end

  def then_I_should_see_the_declarations_error
    expect(page).to have_text(I18n.t('publish.declarations.error'))
  end

  def then_I_accept_the_declarations_with_error_summary
    # we've got an error on the page so the checkboxes all get the same error id for linking
    checkboxes = page.find_all(:css, '#publish-for-review-declarations-declarations-checkboxes-field-error', visible: false)
    checkboxes.each do | checkbox |
      checkbox.check
    end
  end

  def then_I_should_see_the_confirmation
    expect(page).to have_text(I18n.t('publish.publish_for_review.confirmation.heading'))
    expect(page).to have_text(I18n.t('publish.publish_for_review.confirmation.text_1'))
  end

  def then_I_should_see_the_default_no_service_output_warning_message
    expect(environment_section).to have_text(I18n.t('publish.service_output.default', link: I18n.t('publish.service_output.link_text')))
  end

  def then_I_should_not_see_the_default_no_service_output_warning_message
      expect(environment_section).to_not have_text(I18n.t('publish.service_output.default', link: I18n.t('publish.service_output.link_text')))
  end

  def then_I_should_see_the_confirmation_email_no_service_output_warning_message
    expect(environment_section).to have_text(I18n.t('publish.service_output.confirmation_email', link: I18n.t('publish.service_output.link_text')))
  end

  def then_I_should_not_see_the_confirmation_email_no_service_output_warning_message
    expect(environment_section).to_not have_text(I18n.t('publish.service_output.confirmation_email', link: I18n.t('publish.service_output.link_text')))
  end

  def and_I_add_an_email_question
    and_I_return_to_flow_page
    given_I_add_a_single_question_page_with_email
    and_I_add_a_page_url('email')
    when_I_add_the_page
  end

  def then_I_enable_confirmation_email
    editor.settings_link.click
    page.find('#main-content', visible: true)
    editor.submission_settings_link.click
    page.find('#main-content', visible: true)
    editor.send_confirmation_email_link.click
    page.find('#main-content', visible: true)

    and_I_set_confirmation_email(true)
    within("form#confirmation-email-submission-#{environment}") do
      editor.find(:css, "input#confirmation-email-settings-confirmation-email-reply-to-#{environment}-field").set(valid_email)

      find('button[type="submit"]').click
    end
  end

  def then_I_click_the_collecting_information_by_email_link
    environment_section.find('a', text: 'submission settings').click
  end

  def then_I_should_be_on_collecting_information_by_email_page
    expect(page).to have_content(I18n.t('settings.collection_email.heading'))
  end

  def then_I_should_see_the_publish_button
    expect(environment_section.find(:css, 'button')[:'aria-disabled']).to eq(button_disabled)
  end

  def then_the_publish_button_should_be_enabled
    expect(environment_section.find(:css, 'button')[:'aria-disabled']).to eq('false').or eq('')
  end

  def environment_section
    page.find(:css, "section.publish-environment--#{environment}")
  end

  def when_I_visit_the_publishing_page
    sleep 0.5 # Allow time for the page to load
    editor.publishing_link.click
  end

  def and_I_want_to_publish(button_environment)
    page.find('#main-content', visible: true)
    editor.find('#publish-environments').find(:button, text: "Publish to #{button_environment.capitalize}").click
  end

  def when_I_enable_the_submission_settings
    and_I_visit_the_submission_settings_page
    and_I_set_send_by_email(true)
    and_I_set_the_email_field
    and_I_save_my_email_settings
  end

  def and_I_set_the_email_field(value = valid_email)
    editor.find(:css, "#email-settings-service-email-output-#{environment}-field").set(value)
  end

  def and_I_save_my_email_settings
    click_button(I18n.t("settings.submission.#{environment}.save_button"))
  end

  def then_username_and_password_should_be_the_default(environment)
    # defaults to requiring a username and password so the radio is pre selected

    # allow anyone
    expect(page).to_not have_text(allow_anyone_text)
    # set username and password text
    expect(page).to_not have_text(username_and_password_text)
  end

  def then_I_should_see_username_and_password_error
    expect(page).to have_text(I18n.t('activemodel.errors.models.publish_service_creation.password_too_short'))
    expect(page).to have_text(I18n.t('activemodel.errors.models.publish_service_creation.username_too_short'))
  end

  def when_I_enter_invalid_username_and_password(environment, button_environment)
    editor.find("#username_#{environment}").set('foo')
    editor.find("#password_#{environment}").set('bar')
    editor.find('.ui-dialog').find(:button, text: "Publish to #{button_environment.capitalize}").click
  end

  def then_I_should_see_an_error_message(environment, button_environment)
    page.find(:css, '#main-content', visible: true)
    errors = editor.all("form#publish-form-#{environment} .govuk-error-message").map(&:text)
    expect(errors).to match_array(username_and_password_errors)
  end

  def and_I_cancel
    editor.find('.ui-dialog').find(:button, text: 'Cancel').click
  end

  def then_I_should_not_see_warning_both_text
    expect(environment_section.text).to_not include(warning_both)
  end

  def then_I_should_not_see_warning_cya_text
    expect(environment_section).to_not have_content({exact_text: warning_cya})
  end

  def then_I_should_not_see_warning_confirmation_text
    expect(environment_section.text).to_not include(warning_confirmation)
  end

  def then_I_should_see_warning_both_text
    expect(environment_section.text).to have_content(warning_both)
  end

  def then_I_should_see_warning_cya_text
    expect(environment_section.text).to have_content(warning_cya)
  end

  def then_I_should_see_warning_confirmation_text
    expect(environment_section.text).to have_content(warning_confirmation)
  end

  def then_I_should_see_publish_to_test_modal
    expect(editor).to have_content(modal_description)
  end

  def then_I_should_see_the_submission_warning_message
    expect(editor.text).to include(I18n.t("warnings.publish.#{environment}.heading"))
  end

  def then_I_should_see_autocomplete_warnings
    expect(environment_section.text).to include(autocomplete_warning_message)
  end

  def then_I_should_not_see_autocomplete_warnings
    expect(environment_section.text).to_not include(autocomplete_warning_message)
  end
