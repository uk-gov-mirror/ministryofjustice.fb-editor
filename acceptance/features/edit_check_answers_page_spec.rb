require_relative '../spec_helper'

feature 'Edit check your answers page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:url) { 'check-your-answers' }
  let(:heading) { 'Become a sith' }
  let(:send_heading) { 'Welcome to the Dark side of the force' }
  let(:send_body) do
    'Come to the Dark side, we have cookies'
  end
  let(:content_component) do
    'You underestimate the power of the Dark Side.'
  end
  let(:content_extra_component) do
    'If you only knew the power of the dark side'
  end
  let(:optional_content) do
    '[Optional content]'
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'editing page info' do
    given_I_have_a_check_your_answers_page
    and_I_change_the_page_heading(heading)
    and_I_change_the_send_heading(send_heading)
    and_I_change_the_send_body(send_body)
    when_I_save_my_changes
    and_I_return_to_flow_page
    and_I_edit_the_page(url: url)
    then_I_should_see_the_page_heading(heading)
    then_I_should_see_the_page_send_heading(send_heading)
    then_I_should_see_the_page_send_body(send_body)
  end

  scenario 'adding components' do
    given_I_have_a_check_your_answers_page
    and_I_add_a_content_component(
      content: content_component
    )
    and_I_add_a_content_extra_component(
      content: content_extra_component
    )
    when_I_save_my_changes
    and_I_return_to_flow_page
    and_I_edit_the_page(url: url)
    then_I_should_see_the_first_component(content_component)
    then_I_should_see_the_first_extra_component(content_extra_component)
  end

  def given_I_have_a_check_your_answers_page
    given_I_add_a_check_answers_page
    and_I_add_a_page_url(url)
    when_I_add_the_page
  end

  def and_I_change_the_send_heading(send_heading)
    editor.page_send_heading.set(send_heading)
  end

  def and_I_change_the_send_body(send_body)
    editor.page_send_body.set(send_body)
  end

  def and_I_add_a_content_component(content:)
    editor.add_content_area_buttons.last.click
    expect(editor.first_component.text).to eq(optional_content)
    editor.first_component.set(content)
  end

  def and_I_add_a_content_extra_component(content:)
    editor.add_content_area_buttons.first.click
    expect(editor.first_extra_component.text).to eq(optional_content)
    editor.first_extra_component.set(content)
  end

  def then_I_should_see_the_page_send_heading(send_heading)
    expect(editor.page_send_heading.text).to eq(send_heading)
  end

  def then_I_should_see_the_page_send_body(send_body)
    expect(editor.page_send_body.text).to eq(send_body)
  end

  def then_I_should_see_the_first_component(content)
    expect(editor.first_component.text).to eq(content)
  end

  def then_I_should_see_the_first_extra_component(content)
    expect(editor.first_extra_component.text).to eq(content)
  end
end
