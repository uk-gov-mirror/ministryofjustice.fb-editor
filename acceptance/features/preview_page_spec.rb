require_relative '../spec_helper'

feature 'Preview page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'kenobi' }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'preview start page' do
    preview_page = when_I_preview_the_start_page
    then_I_should_preview_the_start_page(preview_page)
  end

  scenario 'preview pages' do
    given_I_have_a_single_question_page_with_text
    and_I_return_to_flow_page
    preview_page = when_I_preview_the_page
    then_I_should_preview_the_page(preview_page)
  end

  def when_I_preview_the_start_page
    editor.preview_page_images.first.hover
    when_I_click_preview_page
  end

  def when_I_preview_the_page
    editor.preview_page_images.last.hover
    when_I_click_preview_page
  end

  def when_I_click_preview_page
    editor.three_dots_button.click

    window_opened_by do
      editor.preview_page_link.click
    end
  end

  def then_I_should_preview_the_start_page(preview_page)
    within_window(preview_page) do
      expect(page.find('button')).to_not be_disabled
      expect(page.text).to include('Before you start')
    end
  end

  def then_I_should_preview_the_page(preview_page)
    within_window(preview_page) do
      expect(page.find('input[type="submit"]')).to_not be_disabled
      expect(page.text).to include('Question')
      expect(page.text).to include('[Optional hint text]')
    end
  end
end
