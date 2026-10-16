# coding: utf-8
module CommonSteps
  OPTIONAL_TEXT = [
    I18n.t('default_text.section_heading'),
    I18n.t('default_text.lede'),
    I18n.t('default_text.content'),
    I18n.t('default_text.option_hint')
  ].freeze
  ERROR_MESSAGE = I18n.t('activemodel.errors.summary_title').freeze
  DELETE_WARNING = [
    I18n.t('warnings.pages_flow.cya_page'),
    I18n.t('warnings.pages_flow.confirmation_page'),
    I18n.t('warnings.pages_flow.both_pages')
  ].freeze

  CREDENTIALS = {
    admin: {
      form_email: 'fb-acceptance-tests@digital.justice.gov.uk',
      ci_email: ENV['ACCEPTANCE_TESTS_ADMIN_USER'],
      ci_password: ENV['ACCEPTANCE_TESTS_ADMIN_PASSWORD']
    },
    user: {
      form_email: 'fb-acceptance-tests-standard@digital.justice.gov.uk',
      ci_email: ENV['ACCEPTANCE_TESTS_STANDARD_USER'],
      ci_password: ENV['ACCEPTANCE_TESTS_STANDARD_PASSWORD']
    }
  }.freeze

  def given_I_am_logged_in(admin: true)
    editor.load
    page.find('#main-content', visible: true)
    editor.sign_in_button.click

    creds = credentials(admin)

    ci_mode? ? login_via_ci(creds) : login_via_form(creds)

    verify_logged_in(admin)
  end

  def credentials(admin)
    admin ? CREDENTIALS[:admin] : CREDENTIALS[:user]
  end

  def ci_mode?
    ENV['CI_MODE'].present?
  end

  def login_via_ci(creds)
    expect(page).to have_content('Please select the log in option that matches your work email')

    # Executing javascript directly as the fields and button are hidden on the
    # login page for the moment
    editor.execute_script(
      "document.getElementById('email').value = '#{creds[:ci_email]}'"
    )
    editor.execute_script(
      "document.getElementById('password').value = '#{creds[:ci_password]}'"
    )
    editor.execute_script(
      "document.getElementById('btn-login').click()"
    )
  end

  def login_via_form(creds)
    editor.sign_in_email_field.set(creds[:form_email])
    editor.sign_in_submit.click
  end

  def verify_logged_in(admin)
    admin ? user_sees_create_new_form_button : user_sees_create_new_form_link
  end

  def user_sees_create_new_form_button
    page.find('button.DialogActivator.govuk-button.govuk-button--secondary.fb-govuk-button--secondary', visible: true)
    expect(page).to have_content(I18n.t('services.create_skip_questionnaire'))
  end

  def user_sees_create_new_form_link
    page.find('a.govuk-button.fb-govuk-button', visible: true)
    expect(page).to have_content(I18n.t('services.create'))
  end

  def given_I_have_a_service(service = service_name)
    editor.load
    page.find(:css, '#main-content', visible: true)
    given_I_want_to_create_a_service
    given_I_add_a_service(service)
    when_I_create_the_service
  end
  alias_method :when_I_try_to_create_a_service_with_the_same_name, :given_I_have_a_service

  def given_I_have_a_service_fixture(name: generate_service_name, fixture: nil)
    visit admin_test_service_path(name, fixture)
  end

  def given_I_have_another_service
    given_I_have_a_service(another_service_name)
  end

  def given_I_add_a_service(service = service_name)
    editor.name_field.set(service)
  end

  def given_I_want_to_create_a_service
    editor.create_service_button.click
  end

  def given_I_have_a_single_question_page_with(component_name)
    given_I_want_to_add_a_single_question_page
    editor.add_component(component_name).click
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def given_I_have_a_single_question_page_with_text
    given_I_have_a_single_question_page_with(I18n.t('components.list.text'))
  end

  def given_I_have_a_single_question_page_with_upload
    given_I_add_a_single_question_page_with_upload
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def given_I_add_a_single_question_page_with_text
    given_I_add_a_single_question_page_with(I18n.t('components.list.text'))
  end

  def given_I_add_a_single_question_page_with(component_name)
    given_I_want_to_add_a_single_question_page
    editor.add_component(component_name).click
  end

  def given_I_add_a_single_question_page_with_radio
    given_I_want_to_add_a_single_question_page
    editor.add_component(I18n.t('components.list.radios')).click
  end

  def given_I_add_a_single_question_page_with_checkboxes
    given_I_want_to_add_a_single_question_page
    editor.add_component(I18n.t('components.list.checkboxes')).click
  end

  def given_I_add_a_single_question_page_with_email
    given_I_want_to_add_a_single_question_page
    editor.add_component(I18n.t('components.list.email')).click
  end

  def given_I_add_a_check_answers_page(page_title)
    editor.connection_menu(page_title).click
    editor.add_check_answers.click
  end

  def given_I_edit_a_check_your_answers_page
    page.find('.govuk-link', text: 'Check your answers').click
  end

  def given_I_add_a_content_page
    and_I_click_on_the_connection_menu
    editor.add_content_page.click
  end

  def given_I_add_a_multiple_question_page
    and_I_click_on_the_connection_menu
    editor.add_multiple_question.click
  end

  def given_I_add_a_confirmation_page
    and_I_click_on_the_connection_menu
    editor.add_confirmation.click
  end

  def given_I_edit_a_confirmation_page(text: 'Application complete' )
    page.find('.govuk-link', text: text).click
  end

  def given_I_add_an_exit_page
    and_I_click_on_the_connection_menu
    editor.add_exit.click
    and_I_add_a_page_url(exit_url)
    when_I_add_the_page
  end

  def given_I_want_to_add_a_single_question_page
    and_I_click_on_the_connection_menu
    editor.add_single_question.hover
  end

  def and_I_edit_the_service
    visit '/services'
    editor.edit_service_link(service_name).click
  end

  def and_I_add_a_content_page(page_title)
    given_I_add_a_content_page
    and_I_add_a_page_url(page_title)
    when_I_add_the_page
    and_I_change_the_page_heading(page_title)
    when_I_save_my_changes
    and_I_return_to_flow_page
  end

  def and_I_edit_the_page(url:)
    page.find('.govuk-link .text', text: url).click
  end

  def and_I_return_to_flow_page
    accept_confirm(wait: 2) { editor.pages_link.click }
  rescue Capybara::ModalNotFound
    editor.pages_link.click
  ensure
    page.find('#main-content', visible: true)
  end

  def and_I_change_the_page_heading(heading)
    editor.page_heading.set(heading)
  end

  def then_I_see_the_updated_page_heading(heading)
    expect(editor.page_heading.text).to eq(heading)
  end

  def and_I_change_the_page_section_heading(section_heading)
    editor.section_heading.set(section_heading)
  end

  def then_I_see_the_updated_page_section_heading(section_heading)
    editor.section_heading.set(section_heading)
  end

  def and_I_change_the_page_lede(lede)
    editor.page_lede.set(lede)
  end

  def then_I_see_the_updated_page_lede(lede)
    editor.page_lede.set(lede)
  end

  def when_I_create_the_service
    editor.modal_create_service_button.click
  end

  def when_I_add_the_page
    editor.add_page_submit_button.last.click
  end

  def when_I_preview_the_page(page_title)
    editor.flow_thumbnail(page_title).hover
    when_I_click_preview_page
  end

  def when_I_click_preview_page
    and_I_click_on_the_three_dots

    window_opened_by do
      editor.preview_page_link.click
    end
  end

  def then_I_should_preview_the_page(preview_page)
    within_window(preview_page) do
      expect(
        page.find('button', text: 'Continue')
      ).to_not be_disabled
      expect(page).to have_content('Question')
      then_I_should_not_see_optional_text
      yield if block_given?
    end
  end

  def when_I_save_my_changes
    # click outside of fields that will make save button re-enable
    editor.service_name.click
    editor.save_page_button.click
  end

  def then_the_save_button_should_be_disabled
    expect(editor).to have_disabled_save_button
  end

  def then_the_save_button_should_be_enabled
    expect(editor).to have_enabled_save_button
  end

  def then_I_should_be_warned_when_leaving_page
    # click outside of fields that will make save button re-enable
    editor.service_name.click

    # dismiss_confirm(wait: 1) { editor.pages_link.click } throws Capybara::ModalNotFound: Unable to find modal dialog.
    # Therefore using page.evaluate_script

    # Headless Chrome hides the native beforeunload prompt from the driver, so
    # trigger it directly. dispatchEvent returns false when a handler cancels the
    # event, which is exactly what produces the browser's "leave page?" warning.
    warned = page.evaluate_script(
      "!window.dispatchEvent(new Event('beforeunload', {cancelable: true}))"
    )
    expect(warned).to be(true)
  end

  def when_I_want_to_select_question_properties
    editor.question_heading.first.click
    editor.question_three_dots_button.click
    # Ensure the menu opened and is in the expected state
    expect(editor).to have_required_question
    expect(editor).to have_no_css('span', text: I18n.t('question.menu.remove'))
  end

  def when_I_want_to_edit_content_component_properties(component)
    editor.service_name.click #in case component is already focused
    element_output(component).click
    component.find('.ActivatedMenuActivator', visible: true).click
  end

  def and_I_want_to_set_a_question_optional
    editor.required_question.click
  end

  def and_I_update_the_question_to_be_optional
    editor.choose 'No', visible: false
    editor.click_button 'Update'
  end

  def given_I_have_a_single_question_page_with_radio
    given_I_add_a_single_question_page_with_radio
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def given_I_add_a_single_question_page_with_upload
    given_I_want_to_add_a_single_question_page
    editor.add_component(I18n.t('components.list.upload')).click
  end

  def and_I_preview_the_form
    window_opened_by do
      editor.preview_form_button.click
    end
  end

  def and_I_add_a_page_url(url = nil)
    path = if url.present?
      url
    else
      page_url # via let(:page_url) { }
    end

    editor.page_url_field.set(path)
  end

  def then_I_should_see_the_confirmation_heading(heading)
    expect(editor.page_heading.text).to eq(heading)
  end
  alias_method :then_I_should_see_the_page_heading, :then_I_should_see_the_confirmation_heading

  def given_I_have_a_check_your_answers_page
    given_I_add_a_check_answers_page
    and_I_add_a_page_url(url)
    when_I_add_the_page
  end
  alias_method :and_I_have_a_check_your_answers_page, :given_I_have_a_check_your_answers_page

  def when_I_preview_the_form
    and_I_return_to_flow_page
    and_I_preview_the_form
  end

  def when_I_focus_editable_content(element)
    element_output(element).click
  end

  def when_I_change_editable_content(element, content:)
    editor.service_name.click #in case component is already focused

    # activate the input element for the content component by clicking on the
    # output element tag first
    element_output(element).click

    # the input element of the content component is what needs to be
    # interacted with in order to set a value
    element.find('[data-element="editable-content-input"]', visible: false).fill_in(with: content)

    # click outside to close the editable component
    editor.service_name.click
  end

  def element_output(element)
    # content component elements
    element.find('[data-element="editable-content-output"] p', visible: :all, wait: 2)
  rescue Capybara::ElementNotFound
    # body elements
    element.find('[data-element="editable-content-output"]', visible: :all, wait: 2)
  end

  def then_I_should_not_see_optional_text
    OPTIONAL_TEXT.each { |optional| expect(page).to have_no_content(optional) }
  end

  def and_I_add_a_content_component(content:)
    if editor.has_add_content_area_buttons?(wait: 1)
      editor.add_content_area_buttons.last.click
    else
      and_I_add_a_multiple_page_content_component
    end

    component = editor.editable_content_areas.last
    and_the_content_component_has_the_optional_content(component)
    when_I_change_editable_content(component, content: content)
  end

  def and_the_content_component_has_the_optional_content(component)
    editor.service_name.click # click outside to close the editable component

    # the output element p tag of a content component is the thing which has
    # the actual text in it
    output_component = component.find('[data-element="editable-content-output"]', visible: false)
    expect(output_component.text).to eq(optional_content)
  end

  def then_I_should_see_an_error_message(*fields)
    expect(page).to have_content(ERROR_MESSAGE)
    if fields.empty?
      expect(page).to have_content('Enter an answer for')
    else
      fields.each { |field| expect(text).to include("Enter an answer for \"#{field}\"")}
    end
  end

  def then_I_should_see_my_content(*expected_text)
    expected_text.each { |text| expect(page).to have_content(text)}
  end

  def then_I_should_not_see_my_content(*expected_text)
    expected_text.each { |text| expect(page).to_not have_content(text)}
  end

  def when_I_want_to_select_component_properties(attribute, text)
    # The attribute might be h2 (heading) which is inside a component container.
    # We want to click the properties button for THAT component.
    element = page.find(attribute, text: text)
    component_container = element.ancestor('.Question, [data-fb-content-id]')
    component_container.scroll_to(:center)
    
    # Click the element to ensure it's "selected" if needed by JS
    element.click 

    menu_activator = component_container.find('.ActivatedMenuActivator', visible: true)
    menu_activator.scroll_to(:center)
    menu_activator.click
  end

  def and_I_click_on_the_three_dots
    editor.wait_until_three_dots_button_visible
    editor.three_dots_button.click
  end

  def and_I_click_on_the_page_menu(flow_title)
    editor.flow_thumbnail(flow_title).hover
    and_I_click_on_the_three_dots
  end

  def and_I_click_on_the_external_start_page_menu
    editor.external_start_page_thumbnail.hover
    and_I_click_on_the_three_dots
  end

  def and_I_click_on_the_branching_point_menu(branch_title)
    editor.hover_branch(branch_title)
    and_I_click_on_the_three_dots
  end

  def and_I_click_on_the_connection_menu
    find('#main-content', visible: true)
    editor.all('.connection-menu-activator').last.click
  end

  def and_I_click_delete
    # Wait for the confirmation modal to be visible
    expect(page).to have_selector('.ui-dialog', visible: true)

    within('.ui-dialog') do
      editor.delete_page_modal_button.click
    end

    # Ensure the modal has closed and the flow page is re-rendered
    expect(page).to have_no_selector('.ui-dialog', wait: 5)
    find('#main-content', visible: true)
  end

  def then_I_should_not_be_able_to_add_page(page_title, page_link)
    find('#main-content', visible: true)
    editor.connection_menu(page_title).click
    # Wait for the menu container to be present/visible if possible, then assert absence.
    # This uses a waiting matcher which retries until timeout.
    expect(editor).to have_no_content(page_link)
    editor.flow_thumbnail(page_title).hover # hides the connection menu
  end

  def then_I_should_be_able_to_add_page(page_title, page_link)
    find('#main-content', visible: true)
    editor.connection_menu(page_title).click
    expect(editor).to have_content(page_link)
    editor.service_name.click #hides the connection menu
  end

  def then_I_should_see_default_service_pages
    find('#main-content', visible: true)
    expect(editor.form_urls.count).to eq(3)
  end

  def then_I_should_see_the_page_flow_in_order(order:)
    expect(editor.form_urls.map(&:text)).to eq(order)
  end

  def and_I_delete_cya_page
    and_I_click_on_the_page_menu('Check your answers')
    editor.delete_page_link.click
    and_I_click_delete
  end

  def when_I_delete_confirmation_page
    and_I_click_on_the_page_menu('Application complete')
    editor.delete_page_link.click
    and_I_click_delete
  end

  def then_I_should_not_see_delete_warnings
    find('#main-content', visible: true)
    expect(editor).to have_no_content(DELETE_WARNING[0])
    expect(editor).to have_no_content(DELETE_WARNING[1])
    expect(editor).to have_no_content(DELETE_WARNING[2])
  end

  def then_I_should_see_delete_warning_cya
    find('#main-content', visible: true)
    expect(editor).to have_content(DELETE_WARNING[0])
  end

  def then_I_should_see_delete_warning_confirmation
    find('#main-content', visible: true)
    expect(editor).to have_content(DELETE_WARNING[1])
  end

  def then_I_should_see_delete_warning_both
    find('#main-content', visible: true)
    expect(editor).to have_content(DELETE_WARNING[2])
  end

  def then_I_should_see_the_modal(modal_title, modal_text)
    expect(page).to have_selector('.ui-dialog', visible: true)
    within('.ui-dialog', visible: true) do
      expect(page).to have_content modal_title
      expect(page).to have_content modal_text
    end
  end

  def and_I_close_the_modal(button_text=nil)
    if button_text
      click_button(button_text);
    else
      click_button('.ui-dialog-titlebar-close')
    end
  end

  # Autocomplete component
  def given_I_add_a_single_question_page_with_autocomplete
    given_I_want_to_add_a_single_question_page
    editor.add_component(I18n.t('components.list.autocomplete')).click
  end

  def and_I_should_see_default_upload_options_warning
    expect(editor).to have_content(I18n.t('dialogs.autocomplete.component_warning'))
  end

  def when_I_click_autocomplete_options_in_three_dots_menu
    editor.question_heading.first.click
    editor.question_three_dots_button.click
    expect(editor).to have_css('span', text: I18n.t('question.menu.upload_options'))
    editor.autocomplete_options.click
  end

  def then_I_should_see_upload_options_modal
    expect(editor.find('.govuk-file-upload')).to be_visible
  end

  def when_I_upload_a_csv_file(csv_file)
    attach_file 'autocomplete_items_file',
    csv_file
    editor.find('.ui-dialog').find(:button, text: upload_button).click
  end

  ## Submission Settings Page
  def and_I_visit_the_submission_settings_page
    editor.settings_link.click
    page.find('#main-content', visible: true)
    editor.submission_settings_link.click
    page.find('#main-content', visible: true)
    editor.send_data_by_email_link.click
    page.find('#main-content', visible: true)
  end

  def and_I_set_send_by_email(value)
    editor.find(:css, "#email-settings-send-by-email-#{environment}-1-field", visible: false).set(value)
  end

  def and_I_set_confirmation_email(value)
    editor.find(:css, "#confirmation-email-settings-send-by-confirmation-email-#{environment}-1-field", visible: false).set(value)
  end

  # Change page position
  def given_I_want_to_change_destination_of_a_page(page)
    editor.connection_menu(page).click
    editor.change_destination_link.click

    # Ensure the modal is open and the destination select is present
    expect(editor).to have_css('.ui-dialog', visible: true)
  end

  def when_I_change_destination_to_page(page)
    select page
    editor.change_next_page_button.click

    # Wait for the modal to close indicating the action completed
    expect(page).to have_no_css('.ui-dialog', wait: Capybara.default_max_wait_time)
  end

  def and_I_select_a_target(target)
    # Use Capybara’s built-in waiting for options to be available
    select(target, from: 'move_target_uuid')
  end

  def and_I_click_the_move_button
    # Click the Move button inside the dialog
    find('button', text: I18n.t('dialogs.move.button')).click

    # Wait for the Move dialog to close (ensures the action completed)
    expect(page).to have_no_css('div#move_targets_list')

    # Optional: ensure main content is visible again
    expect(page).to have_css('#main-content', visible: true)
  end

  def then_I_should_see_the_move_target_list(page_title)
    find('div#move_targets_list', visible: true)
    expect(editor).to have_content(I18n.t('dialogs.move.label', title: page_title))
  end

  ## Confirmation Email
  def when_I_visit_the_confirmation_email_settings_page
    page.find(:css, '#main-content', visible: true)
    editor.click_link(I18n.t('settings.name'))
    editor.click_link(I18n.t('settings.submission.heading'))
    expect(page).to have_content(I18n.t('settings.confirmation_email.heading'))
    editor.click_link(I18n.t('settings.confirmation_email.heading'))
  end

  def when_I_enable_confirmation_email(environment)
    page.find(:css, "input#confirmation-email-settings-send-by-confirmation-email-#{environment}-1-field", visible: false).set(true)
  end

  def when_I_disable_confirmation_email(environment)
    page.find(:css, "input#confirmation-email-settings-send-by-confirmation-email-#{environment}-1-field", visible: false).set(false)
  end

  def then_I_add_a_page_with_email_component
    and_I_return_to_flow_page
    when_I_add_a_single_question_page_with_email_after_start(url: 'new-email')
    when_I_update_the_question_name
    and_I_return_to_flow_page
  end

  def when_I_add_a_single_question_page_with_email_after_start(url:)
    editor.connection_menu(start_page).click
    editor.add_single_question.hover
    editor.add_component(I18n.t('components.list.email')).click
    editor.page_url_field.set(url)
    when_I_add_the_page
  end

  def then_I_fill_in_reply_to_email(email, environment)
    input = editor.find(:css, "input#confirmation-email-settings-confirmation-email-reply-to-#{environment}-field")
    input.fill_in(with: email)
  end

  #Address component
  def given_I_add_a_single_question_page_with_address
    given_I_want_to_add_a_single_question_page
    editor.add_component(I18n.t('components.list.address')).click
  end
end
