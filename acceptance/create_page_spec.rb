require_relative './spec_helper'

feature 'Create page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }

  background do
    editor.load
    given_I_have_a_service
  end

  scenario 'creating a single question page with text' do
    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url
    when_I_add_the_page
    and_I_comeback_to_edit_the_service
    then_I_should_see_the_new_page_url
  end

  scenario 'creating a check answers page' do
    given_I_add_a_check_answers_page
    and_I_add_a_check_answers_page_url
    when_I_add_check_answers_page
    and_I_comeback_to_edit_the_service
    then_I_should_see_the_new_check_answers_page_url
  end

  scenario 'attempt to add a page with an existing url' do
    given_I_add_a_single_question_page_with_text
    and_I_add_an_existing_page_url
    when_I_add_the_page
    then_I_should_see_a_validation_error_message_that_page_url_exists
  end

  # empty until we have the dropdown
  def given_I_add_a_single_question_page_with_text
  end

  def given_I_add_a_check_answers_page
  end

  def and_I_edit_the_service
    editor.edit_service_link(service_name).click
  end

  def and_I_add_a_page_url
    within find('#singlequestion') do
      editor.page_url_field.set('phasma')
    end
  end

  def and_I_add_an_existing_page_url
    within find('#singlequestion') do
      editor.page_url_field.set('/')
    end
  end

  def when_I_add_the_page
    editor.add_single_page_button.click
  end

  def and_I_comeback_to_edit_the_service
    editor.load
    and_I_edit_the_service
  end

  def then_I_should_see_the_new_page_url
    expect(editor.text).to include('phasma')
  end

  def then_I_should_see_a_validation_error_message_that_page_url_exists
    expect(editor.text).to include(
      "Your answer for ‘The page’s relative url - it must not contain any spaces' is already used by another page. Please modify it."
    )
  end

  def and_I_add_a_check_answers_page_url
    within find('#checkanswers') do
      editor.page_url_field.set('aquifolium')
    end
  end

  def when_I_add_check_answers_page
    editor.add_check_answers_page_button.click
  end

  def then_I_should_see_the_new_check_answers_page_url
    expect(editor.text).to include('aquifolium')
  end
end
