module CommonSteps
  def given_I_am_logged_in
    editor.load
    editor.sign_in_button.click

    if ENV['CI_MODE'].present?
      # Executing javascript directly as the fields and button are hidden on the
      # login page for the moment
      editor.execute_script(
        "document.getElementById('email').value = '#{ENV['ACCEPTANCE_TESTS_USER']}'"
      )
      editor.execute_script(
        "document.getElementById('password').value = '#{ENV['ACCEPTANCE_TESTS_PASSWORD']}'"
      )
      editor.execute_script(
        "document.getElementById('btn-login').click()"
      )
    else
      editor.sign_in_email_field.set('form-builder-developers@digital.justice.gov.uk')
      editor.sign_in_submit.click
    end
    sleep(1)
  end

  def given_I_have_a_service(service = service_name)
    editor.load
    given_I_want_to_create_a_service
    given_I_add_a_service(service)
    when_I_create_the_service
  end
  alias_method :when_I_try_to_create_a_service_with_the_same_name, :given_I_have_a_service

  def given_I_have_another_service
    given_I_have_a_service(another_service_name)
  end

  def given_I_add_a_service(service = service_name)
    editor.name_field.set(service)
  end

  def given_I_want_to_create_a_service
    editor.create_service_button.click
  end

  def given_I_have_a_single_question_page_with_text
    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def given_I_add_a_single_question_page_with_text
    given_I_want_to_add_a_single_question_page
    editor.add_text.click
  end

  def given_I_add_a_single_question_page_with_text_area
    given_I_want_to_add_a_single_question_page
    editor.add_text_area.click
  end

  def given_I_add_a_single_question_page_with_number
    given_I_want_to_add_a_single_question_page
    editor.add_number.click
  end

  def given_I_add_a_single_question_page_with_date
    given_I_want_to_add_a_single_question_page
    editor.add_date.click
  end

  def given_I_add_a_single_question_page_with_radio
    given_I_want_to_add_a_single_question_page
    editor.add_radio.click
  end

  def given_I_add_a_single_question_page_with_checkboxes
    given_I_want_to_add_a_single_question_page
    editor.add_checkboxes.click
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

  def and_I_edit_the_page(url:)
    click_link url
  end

  def and_I_return_to_flow_page
    editor.pages_link.click
  end

  def and_I_change_the_page_heading(heading)
    editor.page_heading.set(heading)
  end

  def when_I_create_the_service
    editor.modal_create_service_button.click
  end

  def when_I_add_the_page
    editor.add_page_submit_button.last.click
  end

  def when_I_preview_the_page
    editor.preview_page_images.last.hover
    when_I_click_preview_page
  end

  def when_I_click_preview_page
    editor.three_dots_button.click

    window_opened_by do
      editor.preview_page_link.click
    end
  end

  def then_I_should_preview_the_page(preview_page)
    within_window(preview_page) do
      expect(page.find('input[type="submit"]')).to_not be_disabled
      expect(page.text).to include('Question')
      yield if block_given?
    end
  end

  def when_I_save_my_changes
    # click outside of fields that will make save button re-enable
    editor.service_name.click
    expect(editor.save_page_button).to_not be_disabled
    editor.save_page_button.click
  end

  def given_I_have_a_single_question_page_with_radio
    given_I_add_a_single_question_page_with_radio
    and_I_add_a_page_url
    when_I_add_the_page
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

  def and_I_change_the_page_heading(heading)
    editor.page_heading.set(heading)
  end

  def then_I_should_see_the_confirmation_heading(heading)
    expect(editor.page_heading.text).to eq(heading)
  end
  alias_method :then_I_should_see_the_page_heading, :then_I_should_see_the_confirmation_heading
end
