require_relative '../spec_helper'

feature 'Undo redo page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:fixture) { 'undo_redo_fixture' }
  let(:page_1) { 'page 1' }
  let(:page_2) { 'page 2' }

  let(:original_flow_titles) do
    [
      'Service name goes here',
      'page 1',
      'page 2',
      'Check your answers',
      'Application complete'
    ]
  end
  let(:move_flow) do
    [
      'Service name goes here',
      'page 2',
      'page 1',
      'Check your answers',
      'Application complete'
    ]
  end

  let(:next_page_flow) do
    [
      "Service name goes here",
      "page 1",
      "page 2",
      "You won’t receive any user data without a check answers page and a confirmation page"
    ]
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'undo_redo_fixture')
  end

  scenario 'when moving page' do
    and_I_click_on_the_page_menu(page_1)
    editor.move_page_link.click
    then_I_should_see_the_move_target_list(page_1)
    and_I_select_a_target(page_2)
    and_I_click_the_move_button
    then_page_1_should_be_after_page_2
    and_I_click_button('undo_move')
    then_page_2_should_be_after_page_1
    and_I_click_button('redo_move')
    then_page_1_should_be_after_page_2
  end

  scenario 'when changing next page' do
    given_I_want_to_change_destination_of_a_page(page_2)
    when_I_change_destination_to_page('page 1')
    then_next_to_page_2_is_page_1
    and_I_click_button('undo_change_next_page')
    then_page_2_should_be_after_page_1
    and_I_click_button('redo_change_next_page')
    then_next_to_page_2_is_page_1
  end

  def then_page_1_should_be_after_page_2
    then_the_flow_should_be(move_flow)
  end

  def then_page_2_should_be_after_page_1
    then_the_flow_should_be(original_flow_titles)
  end

  def then_next_to_page_2_is_page_1
    then_the_flow_should_be(next_page_flow)
  end

  def and_I_click_button(name)
    page.find(:css, '#main-content', visible: true)
    page.find('.fb-govuk-button', text: I18n.t("actions.undo_redo.#{name}")).click
  end
end
