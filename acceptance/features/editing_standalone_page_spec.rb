require_relative '../spec_helper'

feature 'Edit standalone pages' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:cookies_heading) { 'Updated cookies heading' }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'editing footer standalone pages' do
    given_I_have_footer_pages
    and_I_edit_the_cookies_page
    and_I_change_the_page_heading(cookies_heading)
    when_I_save_my_changes
    then_I_should_see_the_new_cookies_heading
  end

  def given_I_have_footer_pages
    editor.footer_pages_links.click
  end

  def and_I_edit_the_cookies_page
    editor.cookies_link.click
  end

  def then_I_should_see_the_new_cookies_heading
    expect(editor.page_heading.text).to eq(cookies_heading)
  end
end
