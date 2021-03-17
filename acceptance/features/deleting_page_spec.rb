require_relative '../spec_helper'

feature 'Deleting page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'dooku' }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'when deleting start page' do
    given_I_want_to_delete_the_start_page
    when_I_delete_the_page
    and_I_return_to_flow_page
    then_I_should_still_see_the_start_page # Do not delete precious start pages
  end

  scenario 'when deleting other pages' do
    given_I_have_a_single_question_page_with_text
    and_I_return_to_flow_page
    and_I_want_to_delete_the_page_that_I_created
    when_I_delete_the_page
    and_I_return_to_flow_page
    then_I_should_not_see_the_deleted_page_anymore
  end

  def given_I_want_to_delete_the_start_page
    editor.preview_page_images.first.hover
    editor.three_dots_button.click
  end

  def and_I_want_to_delete_the_page_that_I_created
    editor.preview_page_images.last.hover
    editor.three_dots_button.click
  end

  def when_I_delete_the_page
    accept_confirm do
      editor.delete_page_link.click
    end
  end

  def then_I_should_still_see_the_start_page
    expect(editor.form_urls.map(&:text)).to eq(['/'])
  end

  def then_I_should_not_see_the_deleted_page_anymore
    expect(editor.form_urls.map(&:text)).to eq(['/'])
  end
end
