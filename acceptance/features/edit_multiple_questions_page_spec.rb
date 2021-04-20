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
