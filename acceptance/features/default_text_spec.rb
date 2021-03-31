require_relative '../spec_helper'

feature 'Default text' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'star-wars-question' }
  let(:question) do
    'Which program do Jedi use to open PDF files?'
  end
  let(:editable_options) do
    ['Adobe-wan Kenobi', 'PDFinn']
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'Text component with default text' do
    given_I_have_a_single_question_page_with_text
    then_I_should_see_default_text
    and_I_return_to_flow_page
    preview_page = when_I_preview_the_page
    then_I_should_preview_the_page(preview_page) do
      and_I_should_not_see_the_default_text
    end
  end

  scenario 'Text component with custom hint from the user' do
    given_I_have_a_single_question_page_with_text
    when_I_customise_hint
    when_I_save_my_changes
    and_I_return_to_flow_page
    preview_page = when_I_preview_the_page
    then_I_should_preview_the_page(preview_page) do
      and_I_see_the_custom_hint
    end
  end

  scenario 'Radio component with default text' do
    given_I_have_a_single_question_page_with_radio
    then_I_should_see_default_text_in_label_and_options
    and_I_return_to_flow_page
    preview_page = when_I_preview_the_page
    then_I_should_preview_the_page(preview_page) do
      and_I_should_not_see_the_default_text
    end
  end

  scenario 'Radio component with custom hint from the user' do
    given_I_have_a_single_question_page_with_radio
    when_I_customise_all_hints
    when_I_save_my_changes
    and_I_return_to_flow_page
    preview_page = when_I_preview_the_page
    then_I_should_preview_the_page(preview_page) do
      and_I_see_all_custom_hints
    end
  end

  def then_I_should_see_default_text
    expect(editor.question_hint.text).to eq('[Optional hint text]')
  end

  def and_I_should_not_see_the_default_text
    expect(page.text).to_not include('[Optional hint text]')
  end

  def when_I_customise_hint
    editor.question_hint.set('This is where you add your name')
  end

  def and_I_see_the_custom_hint
    expect(page.text).to include('This is where you add your name')
  end

  def then_I_should_see_default_text_in_label_and_options
    expect(editor.all_hints.map(&:text)).to eq(['[Optional hint text]', '[Optional hint text]', '[Optional hint text]'])
  end

  def when_I_customise_all_hints
    editor.all_hints.each do |hint|
      hint.set('This is a radio button')
    end
  end

  def and_I_see_all_custom_hints
    expect(page.text).to include('This is a radio button')
  end
end
