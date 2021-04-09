require_relative '../spec_helper'

feature 'Preview form' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'preview the whole form' do
    given_I_add_all_pages_for_a_form
    preview_form = when_I_preview_the_form
    then_I_can_navigate_until_the_end_of_the_form(preview_form)
  end

  def given_I_add_all_pages_for_a_form
    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url('name')
    when_I_add_the_page
    when_I_update_the_question_name('Full name')
    and_I_return_to_flow_page

    given_I_add_a_single_question_page_with_date
    and_I_add_a_page_url('date-of-birth')
    when_I_add_the_page
    when_I_update_the_question_name('Date of birth')
    and_I_return_to_flow_page

    given_I_add_a_check_answers_page
    and_I_add_a_page_url('cya')
    when_I_add_the_page
    and_I_return_to_flow_page

    given_I_add_a_confirmation_page
    and_I_add_a_page_url('confirmation')
    when_I_add_the_page
  end

  def when_I_update_the_question_name(question_name)
    editor.question_heading.first.set(question_name)
    when_I_save_my_changes
  end

  def when_I_preview_the_form
    and_I_return_to_flow_page
    and_I_preview_the_form
  end

  def then_I_can_navigate_until_the_end_of_the_form(preview_form)
    within_window(preview_form) do
      expect(page.text).to include('This is your start page')
      page.click_button 'Start now'
      expect(page.text).to include('Full name')
      page.fill_in 'Full name', with: 'Charmy Pappitson'
      page.click_button 'Continue'
      expect(page.text).to include('Date of birth')
      page.fill_in 'Day', with: '03'
      page.fill_in 'Month', with: '06'
      page.fill_in 'Year', with: '2002'
      page.click_button 'Continue'
      expect(page.text).to include('Check your answers')
      expect(page.text).to include('Charmy Pappitson')
      expect(page.text).to include('03 June 2002')
      page.click_button 'Accept and send application'
      expect(page.text).to include('Application complete')
    end
  end
end
