require_relative '../spec_helper'

feature 'Edit single question page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'star-wars-question' }
  let(:question) do
    'Which program do Jedi use to open PDF files?'
  end
  let(:editable_options) do
    ['Adobe-wan Kenobi', 'PDFinn']
  end
  let(:section_heading) { 'I open at the close' }
  let(:default_section_heading) { I18n.t('default_text.section_heading') }
  let(:new_hint) { 'This is a hint' }
  let(:default_hint) { I18n.t('default_text.hint') }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'default_new_service_fixture')
  end

  shared_examples 'editing a component' do
    scenario 'editing heading, section and hint text' do
      given_I_have_a_single_question_page_with(component_name)
      and_I_have_optional_section_heading_text
      then_the_save_button_should_be_disabled
      when_I_update_the_question_name
      when_I_update_the_optional_section_heading
      when_I_delete_the_optional_section_heading_text
      when_I_update_the_optional_hint_text
      when_I_delete_the_optional_hint_text
      and_I_return_to_flow_page
      then_I_should_see_my_changes_on_preview
    end
  end

  context 'when editing a text component' do
    let(:component_name) { I18n.t('components.list.text') }

    it_behaves_like 'editing a component'
  end

  context 'when editing a textarea component' do
    let(:component_name) { I18n.t('components.list.textarea') }

    it_behaves_like 'editing a component'
  end

  context 'when editing a number component' do
    let(:component_name) { I18n.t('components.list.number') }

    it_behaves_like 'editing a component'
  end

  scenario 'when editing upload component' do
    given_I_have_a_single_question_page_with_upload
    and_I_can_add_a_content_area
    and_I_have_optional_section_heading_text
    then_the_save_button_should_be_disabled
    when_I_update_the_question_name
    and_I_return_to_flow_page
    then_I_should_see_my_changes_on_preview
  end

  context 'when editing a date component' do
    let(:component_name) { I18n.t('components.list.date') }

    it_behaves_like 'editing a component'
  end

  context 'when editing a email component' do
    let(:component_name) { I18n.t('components.list.email') }

    it_behaves_like 'editing a component'
  end

  context 'when editing a address component' do
    let(:component_name) { I18n.t('components.list.address') }

    it_behaves_like 'editing a component'
  end

  def and_I_edit_the_question
    editor.question_heading.first.set(question)
  end

  def and_I_edit_the_optional_section_heading
    page.first('.fb-section_heading').set(section_heading)
  end

  def then_I_should_see_my_updated_section_heading
    expect(editor).to have_content(section_heading)
  end

  def then_I_should_see_the_default_section_heading
    editor.service_name.click
    expect(editor.section_heading_hint.text).to eq(default_section_heading)
  end

  def then_I_should_see_the_default_hint_text
    editor.service_name.click
    expect(editor.question_hint.text).to eq(default_hint)
  end

  def then_I_should_see_my_updated_hint_text
    expect(editor).to have_content(new_hint)
  end

  def and_I_go_to_the_page_that_I_edit(preview_form)
    within_window(preview_form) do
      page.click_button 'Start now'
    end
  end

  def when_I_save_my_changes
    # click outside of fields that will make save button re-enable
    editor.service_name.click
    expect(editor.save_page_button['aria-disabled']).to eq('false')
    editor.save_page_button.click
    expect(editor.save_page_button['aria-disabled']).to eq('true')
  end

  def when_I_update_the_question_name
    and_I_edit_the_question
    then_I_should_be_warned_when_leaving_page
    when_I_save_my_changes
  end

  def when_I_update_the_optional_section_heading
    and_I_edit_the_optional_section_heading
    when_I_save_my_changes
    then_I_should_see_my_updated_section_heading
  end

  def when_I_delete_the_optional_section_heading_text
    editor.section_heading_hint.set(' ')
    when_I_save_my_changes
    then_I_should_see_the_default_section_heading
  end

  def when_I_update_the_optional_hint_text
    editor.question_hint.set(new_hint)
    when_I_save_my_changes
    then_I_should_see_my_updated_hint_text
  end

  def when_I_delete_the_optional_hint_text
    editor.question_hint.set(' ')
    when_I_save_my_changes
    then_I_should_see_the_default_hint_text
  end

  def and_I_edit_the_options
    editor.editable_options.first.set(editable_options.first)
    editor.editable_options.last.set(editable_options.last)
  end

  def then_I_should_see_my_changes_on_preview
    preview_form = and_I_preview_the_form

    and_I_go_to_the_page_that_I_edit(preview_form)
    then_I_should_see_my_changes_in_the_form(preview_form)
    then_I_should_not_see_optional_text

    preview_form
  end

  def then_I_should_see_my_changes_in_the_form(preview_form)
    within_window(preview_form) do
      expect(page).to have_content(question)
    end
  end

  def and_I_have_optional_section_heading_text
    editor.service_name.click
    expect(page).to have_content(I18n.t('default_text.section_heading'))
  end

  def and_I_can_add_a_content_area
    content = 'This upload page is fantastic'
    expect(page).to have_content('[Optional content]')
    component = editor.page_body
    when_I_change_editable_content(component, content:)
    when_I_save_my_changes
    expect(page).to have_content(content)
  end
end
