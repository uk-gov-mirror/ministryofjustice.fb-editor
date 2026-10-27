require_relative '../spec_helper'

feature 'Save and Return page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:start_page) { 'Service name goes here' }
  let(:save_and_return_checkbox) { 'input#save-and-return-settings-save-and-return-1-field' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name)
    when_I_visit_the_save_and_return_page
    then_I_should_see_the_save_and_return_settings_page
  end

  scenario 'when I enable save and return' do
    with_setting(save_and_return_checkbox, true)
    click_button(I18n.t('actions.save'))
    then_the_save_should_have_finished
    then_checkbox_should_remain_checked(save_and_return_checkbox, true)

    # when editing a page
    and_I_return_to_flow_page
    and_I_edit_the_page(url: 'Page b')
    save_and_return_button_should_be_disabled

    # in preview
    and_I_return_to_flow_page
    preview_page = when_I_preview_the_page('Page b')
    save_and_return_button_should_be_disabled_in_preview(preview_page)
  end

  scenario 'when I disable save and return' do
    with_setting(save_and_return_checkbox, true)
    click_button(I18n.t('actions.save'))
    then_the_save_should_have_finished
    then_checkbox_should_remain_checked(save_and_return_checkbox, true)

    with_setting(save_and_return_checkbox, false)
    click_button(I18n.t('actions.save'))
    then_the_save_should_have_finished
    then_checkbox_should_remain_checked(save_and_return_checkbox, false)

    # when editing a page
    and_I_return_to_flow_page
    and_I_edit_the_page(url: 'Page b')
    then_I_should_not_see_save_and_return_button

    # in preview
    and_I_return_to_flow_page
    preview_page = when_I_preview_the_page('Page b')
    then_I_should_not_see_save_and_return_button_in_preview(preview_page)
  end

  ## Save and Return Settings Page
  def when_I_visit_the_save_and_return_page
    page.find(:css, '#main-content', visible: true)
    editor.click_link(I18n.t('settings.name'))
    expect(page).to have_content(I18n.t('settings.save_and_return.lede'))
    editor.click_link(I18n.t('settings.save_and_return.heading'))
  end

  def then_I_should_see_the_save_and_return_settings_page
    expect(page).to have_content(I18n.t('settings.save_and_return.heading'))
    expect(page).to have_content(I18n.t('settings.save_and_return.description'))
  end

  def then_checkbox_should_remain_checked(attribute, checked)
    element = find(attribute, visible: false)
    expect(element.checked?).to eq(checked)
  end

  def with_setting(setting, value)
    page.find(:css, setting, visible: false).set(value)
  end

  def save_and_return_button_should_be_disabled
    expect(page).to have_button('Save for later', disabled: true)
  end

  def save_and_return_button_should_be_disabled_in_preview(preview_page)
    within_window(preview_page) do
      expect(
        page.find('button', text: 'Continue')
      ).to_not be_disabled
      save_and_return_button_should_be_disabled
    end
  end

  def then_I_should_not_see_save_and_return_button
    expect(page).to_not have_button('Save for later')
  end

  def then_I_should_not_see_save_and_return_button_in_preview(preview_page)
    within_window(preview_page) do
      expect(
        page.find('button', text: 'Continue')
      ).to_not be_disabled

      then_I_should_not_see_save_and_return_button
    end
  end
end
