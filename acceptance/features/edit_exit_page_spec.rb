require_relative '../spec_helper'

feature 'Edit exit pages' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:exit_url) { 'exit' }
  let(:exit_heading) { 'Updated heading' }
  let(:exit_section_heading) { 'Updated section heading' }
  let(:exit_lede) { 'Updated lede' }
  let(:content_component) do
    'Give me content'
  end
  let(:optional_content) do
    I18n.t('default_text.content')
  end
  let(:default_exit_page_title) { 'Title' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'default_new_service_fixture')
    and_I_add_a_content_page('Content Page')
  end

  scenario 'updates all fields' do
    given_I_add_an_exit_page
    then_I_should_not_see_the_continue_button
    and_I_change_the_page_heading(exit_heading)
    and_I_change_the_page_section_heading(exit_section_heading)
    and_I_change_the_page_lede(exit_lede)
    when_I_save_my_changes
    and_I_return_to_flow_page
    and_I_edit_the_page(url: exit_heading)
    then_I_see_the_updated_page_heading(exit_heading)
    then_I_see_the_updated_page_section_heading(exit_section_heading)
    then_I_see_the_updated_page_lede(exit_lede)
    preview_form = when_I_preview_the_form_until_the_exit_page
    then_I_should_stop_until_the_exit_page(preview_form)
  end

  scenario 'adding components' do
    given_I_add_an_exit_page
    then_I_should_not_see_the_continue_button
    and_I_add_a_content_component(
      content: content_component
    )
    when_I_save_my_changes
    and_I_return_to_flow_page
    and_I_edit_the_page(url: default_exit_page_title)
    then_I_should_see_the_component(content_component)
  end

  scenario 'deleting components' do
    given_I_add_an_exit_page
    then_I_should_not_see_the_continue_button
    and_I_add_a_content_component(
      content: content_component
    )
    when_I_save_my_changes
    and_I_return_to_flow_page
    and_I_edit_the_page(url: default_exit_page_title)
    then_I_should_see_the_component(content_component)
    when_I_want_to_select_component_properties('[data-element="editable-content-output"]', content_component)
    and_I_want_to_delete_a_content_component
    then_I_should_not_see_my_content(content_component)
  end

  def then_I_should_see_the_component(content)
    expect(editor.first_component.find('[data-element="editable-content-output"]', visible: :all).text).to eq(content)
  end

  def then_I_should_not_see_the_continue_button
    expect(page).to have_no_content(I18n.t('actions.continue'))
  end

  def when_I_preview_the_form_until_the_exit_page
    and_I_return_to_flow_page
    when_I_preview_the_form
  end

  def then_I_should_stop_until_the_exit_page(preview_form)
    within_window(preview_form) do
      expect(page).to have_button('Start now')
      page.click_button 'Start now'

      expect(page).to have_button(I18n.t('actions.continue'))
      page.click_button I18n.t('actions.continue')

      expect(page).to have_current_path(/\/preview\/exit/)
      expect(page).to have_no_selector('button')
    end
  end
end
