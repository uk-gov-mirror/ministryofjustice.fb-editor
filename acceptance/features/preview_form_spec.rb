require_relative '../spec_helper'

feature 'Preview form' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:multiple_page_heading) do
    'Multiple Page'
  end
  let(:optional_content) do
    '[Optional content]'
  end
  let(:content_component) do
    "I am a doctor not a doorstop"
  end
  let(:text_component_question) do
    'What is the name of the Gungan who became a taxi driver?'
  end
  let(:textarea_component_question) do
    'What droid always takes the long way around?'
  end
  let(:content_page_heading) do
    'There is no bathroom'
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'preview the whole form' do
    given_I_add_all_pages_for_a_form
    preview_form = when_I_preview_the_form
    then_I_can_navigate_until_the_end_of_the_form(preview_form)
  end

  scenario 'preview the standalone pages' do
    preview_form = when_I_preview_the_form
    then_I_should_preview_the_cookies_page(preview_form)
  end

  def then_I_should_preview_the_cookies_page(preview_form)
    within_window(preview_form) do
      page.find_link('Cookies').click
      expect(page.find('h1').text).to eq('Cookies')
    end
  end

  def given_I_add_all_pages_for_a_form
    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url('name')
    when_I_add_the_page
    when_I_update_the_question_name('Full name')
    and_I_return_to_flow_page

    given_I_add_a_multiple_question_page
    and_I_add_a_page_url('multi')
    when_I_add_the_page
    and_I_change_the_page_heading(multiple_page_heading)
    and_I_add_a_text_component
    and_I_change_the_text_component(text_component_question)
    when_I_update_the_question_name('Multiple Question page')
    and_I_add_a_multiple_page_content_component(content: content_component)
    and_I_add_a_textarea_component
    and_I_change_the_textarea_component(textarea_component_question, component: 2)
    when_I_save_my_changes
    and_I_return_to_flow_page

    given_I_add_a_content_page
    and_I_add_a_page_url('content-page')
    when_I_add_the_page
    and_I_change_the_page_heading(content_page_heading)
    when_I_save_my_changes
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

  def and_I_add_a_multiple_page_content_component(content:)
    and_I_add_a_component
    and_I_add_a_content_area
    expect(editor.second_component.text).to eq(optional_content)
    editor.second_component.set(content)
  end

  def when_I_update_the_question_name(question_name)
    editor.question_heading.first.set(question_name)
    when_I_save_my_changes
  end

  def then_I_can_navigate_until_the_end_of_the_form(preview_form)
    within_window(preview_form) do
      expect(page.text).to include('Service name goes here')
      page.click_button 'Start now'
      expect(page.text).to include('Full name')
      page.fill_in 'Full name', with: 'Charmy Pappitson'
      page.click_button 'Continue'
      expect(page.text).to include(content_component)
      page.fill_in text_component_question, with: 'Car Car Binks'
      page.fill_in textarea_component_question, with: 'R2-Detour'
      page.click_button 'Continue'
      expect(page.text).to include(content_page_heading)
      page.click_button 'Continue'
      expect(page.text).to include('Date of birth')
      page.fill_in 'Day', with: '03'
      page.fill_in 'Month', with: '06'
      page.fill_in 'Year', with: '2002'
      page.click_button 'Continue'
      expect(page.text).to include('Check your answers')
      expect(page.text).to include('Charmy Pappitson')
      expect(page.text).to include('03 June 2002')
      then_I_should_not_see_content_page_in_check_your_answers(page)
      then_I_should_not_see_content_components_in_check_your_answers(page)
      page.click_button 'Accept and send application'
      expect(page.text).to include('Application complete')
    end
  end

  def then_I_should_not_see_content_page_in_check_your_answers(page)
    expect(page.text).to_not include(content_component)
  end

  def then_I_should_not_see_content_components_in_check_your_answers(page)
    expect(page.text).to_not include(content_page_heading)
  end
end
