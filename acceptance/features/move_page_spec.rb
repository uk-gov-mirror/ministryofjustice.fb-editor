require_relative '../spec_helper'

feature 'Move a page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:fixture) { 'move_page_fixture' }
  let(:page_b) { 'Page B' }
  let(:page_c) { 'Page C' }
  let(:page_f) { 'Page F' }
  let(:page_h) { 'Page H' }
  let(:branching_point_2_branching_1) { 'Branching point 2 (Branch 1)'}
  let(:original_flow_titles) do
    [
      'Service name goes here',
      'Page B',
      'Page D',
      'Branching point 1',
      'Page E',
      'Page I',
      'Page F',
      'Branching point 2',
      'Page H',
      'Page K',
      'Page G',
      'Page L',
      'Check your answers',
      'Complaint sent'
    ]
  end
  let(:page_h_after_page_b_flow) do
    [
      'Service name goes here',
      'Page B',
      'Page H',
      'Page D',
      'Branching point 1',
      'Page E',
      'Page I',
      'Page F',
      'Branching point 2',
      'Page K',
      'Page G',
      'Page L',
      'Check your answers',
      'Complaint sent'
    ]
  end
  let(:page_h_after_branching_point_2_branch_1_flow) do
    # the layout is iterated over vertically by column
    [
      'Service name goes here',
      'Page B',
      'Page D',
      'Branching point 1',
      'Page E',
      'Page I',
      'Page F',
      'Branching point 2',
      'Page H',
      'Page K',
      'Page G',
      'Page L',
      'Check your answers',
      'Complaint sent'
    ]
  end
  let(:page_c_in_main_flow) do
    [
      'Service name goes here',
      'Page B',
      'Page D',
      'Branching point 1',
      'Page E',
      'Page I',
      'Page F',
      'Branching point 2',
      'Page C',
      'Page H',
      'Page K',
      'Page G',
      'Page L',
      'Check your answers',
      'Complaint sent'
    ]
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name, fixture: fixture)
  end

  scenario 'moving pages' do
    and_I_open_the_page_menu(page_h)
    editor.move_page_link.click
    then_I_should_see_the_move_target_list(page_h)
    and_I_select_a_target(page_b)
    and_I_click_the_move_button
    then_page_H_should_be_after_page_B

    and_I_open_the_page_menu(page_h)
    editor.move_page_link.click
    then_I_should_see_the_move_target_list(page_h)
    and_I_select_a_target(branching_point_2_branching_1)
    and_I_click_the_move_button
    then_page_H_should_be_the_branching_point_2_branch_1_destination

    and_I_open_the_page_menu(page_c)
    editor.move_page_link.click
    then_I_should_see_the_move_target_list(page_c)
    and_I_select_a_target(page_f)
    and_I_click_the_move_button
    then_page_C_should_be_part_of_the_main_flow
  end

  scenario 'no default next warning message' do
    and_I_click_on_the_page_menu('Page G')
    editor.move_page_link.click
    then_I_should_see_the_no_default_next_warning
    and_I_click_understood
    then_no_pages_should_have_moved
  end

  scenario 'stacked branching not supported warning message' do
    and_I_click_on_the_page_menu('Page I')
    editor.move_page_link.click
    then_I_should_see_the_stacked_branches_not_supported_warning
    and_I_click_understood
    then_no_pages_should_have_moved
  end

  def and_I_open_the_page_menu(flow_title)
    find('#main-content', visible: true)

    # Hover over the page, then click the menu button that belongs to it.
    # Each button has aria-label 'Actions for page <title>'.
    find('.flow-thumbnail', text: flow_title).hover
    menu_label = I18n.t('pages.flow_page_menu_label', title: flow_title)
    find("button[aria-label='#{menu_label}']").click
  end

  def then_page_H_should_be_after_page_B
    then_the_flow_should_be(page_h_after_page_b_flow)
  end

  def then_page_H_should_be_the_branching_point_2_branch_1_destination
    then_the_flow_should_be(page_h_after_branching_point_2_branch_1_flow)
  end

  def then_page_C_should_be_part_of_the_main_flow
    then_the_flow_should_be(page_c_in_main_flow)
    expect(page).to have_no_css('.flow-detached-group .flow-item')
  end

  def then_I_should_see_the_no_default_next_warning
    find('div#branch_destination_no_default_next', visible: true)
    expect(editor).to have_content(I18n.t('dialogs.move.branch_destination_no_default_next_message'))
  end

  def then_I_should_see_the_stacked_branches_not_supported_warning
    find('div#stacked_branches_not_supported', visible: true)
    expect(editor).to have_content(I18n.t('dialogs.move.stacked_branches_not_supported_message'))
  end

  def then_no_pages_should_have_moved
    then_the_flow_should_be(original_flow_titles)
  end

  def and_I_click_understood
    find('button', text: I18n.t('dialogs.button_understood')).click
  end
end
