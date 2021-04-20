require_relative '../spec_helper'

feature 'Add page in the middle flow' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'palpatine' }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'adding page after first page and before last page' do
    given_I_have_a_single_question_page_with_text
    and_I_return_to_flow_page
    when_I_add_a_single_question_page_with_radio_after_start(url: 'new-page-url')
    and_I_return_to_flow_page
    then_I_should_see_the_page_flow_in_order(order: ['/', 'new-page-url', 'palpatine'])
  end

  def when_I_add_a_single_question_page_with_radio_after_start(url:)
    editor.preview_page_images.first.hover
    editor.three_dots_button.click
    editor.add_page_here_link.click
    editor.add_single_question.hover
    editor.add_radio.click
    editor.page_url_field.set(url)
    when_I_add_the_page
    # expect to be on the page created (radio component page)
    expect(editor.radio_options.size).to be(2)
  end

  def then_I_should_see_the_page_flow_in_order(order:)
    expect(editor.form_urls.map(&:text)).to eq(order)
  end
end
