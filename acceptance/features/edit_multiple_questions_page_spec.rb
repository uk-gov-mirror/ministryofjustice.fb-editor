require_relative '../spec_helper'

feature 'Edit multiple questions page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:url) { 'hakuna-matata' }
  let(:page_heading) { 'Star wars questions' }
  let(:text_component_question) do
    'C-3P0 is fluent in how many languages?'
  end
  let(:textarea_component_question) do
    'How Did Maz Kanata End Up With Luke`s Lightsaber?'
  end
  let(:radio_component_question) do
    'How old is Yoda when he dies?'
  end
  let(:radio_component_options) { ['900 years old'] }
  let(:checkboxes_component_question) do
    'Tell us what are the star wars movies called'
  end
  let(:checkboxes_component_options) do
    ['Prequels']
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'adding and updating components' do
    given_I_have_a_multiple_questions_page
    and_I_add_a_text_component
    and_I_add_a_textarea_component
    and_I_add_a_radio_component
    and_I_add_a_checkbox_component
    and_I_update_the_components
    when_I_save_my_changes
    and_I_return_to_flow_page
    preview_form = and_I_preview_the_form
    then_I_can_answer_the_questions_in_the_page(preview_form)
  end

  def given_I_have_a_multiple_questions_page
    given_I_add_a_multiple_question_page
    and_I_add_a_page_url(url)
    when_I_add_the_page
  end

  def and_I_add_a_text_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_text.click
  end

  def and_I_add_a_component
    editor.add_a_component_button.click
  end

  def and_I_add_a_question
    editor.question_component.hover
  end

  def and_I_add_a_textarea_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_text_area.click
  end

  def and_I_add_a_radio_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_radio.click
  end

  def and_I_add_a_checkbox_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_checkboxes.click
  end

  def and_I_update_the_components
    and_I_change_the_page_heading(page_heading)
    and_I_change_the_text_component(text_component_question)
    and_I_change_the_textarea_component(textarea_component_question)
    and_I_change_the_radio_component(
      radio_component_question,
      options: radio_component_options
    )
    and_I_change_the_checkboxes_component(
      checkboxes_component_question,
      options: checkboxes_component_options
    )
  end

  def and_I_change_the_text_component(question)
    and_I_change_the_component(question, component: 0, tag: 'label')
  end

  def and_I_change_the_textarea_component(question)
    and_I_change_the_component(question, component: 1, tag: 'label')
  end

  def and_I_change_the_radio_component(question, options:)
    and_I_change_the_component(question, component: 2, tag: 'legend', options: options)
  end

  def and_I_change_the_checkboxes_component(question, options:)
    and_I_change_the_component(question, component: 3, tag: 'legend', options: options)
  end

  def and_I_change_the_component(question, component:, tag:, options: nil)
    element = editor.find(
      :xpath,
      "//*[@data-fb-content-id='page[components[#{component}]]']")
    question_name = element.find("#{tag} .EditableElement")
    question_name.set(question)

    if options
      options.each_with_index do |option, index|
        element.all('label')[index].set(option)
      end
    end
  end

  def then_I_can_answer_the_questions_in_the_page(preview_form)
    within_window(preview_form) do
      expect(page.text).to include('Service name goes here')
      page.click_button 'Start now'
      page.fill_in 'C-3P0 is fluent in how many languages?',
        with: 'Fluent in over six million forms of communication.'
      page.fill_in 'How Did Maz Kanata End Up With Luke`s Lightsaber?',
        with: 'Who knows?'
      page.choose '900 years old', visible: false
      page.check 'Prequels', visible: false
      page.click_button 'Continue'

      # There are no next pages but it means that the continue work and the
      # multiple question is working since filling the form above worked
      # gracefully.
      expect(page.text).to include("The page you were looking for doesn't exist.")
    end
  end
end
