require_relative '../spec_helper'

feature 'Conditional content' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:fixture) { 'conditional_content_fixture' }
  let(:optional_content) { I18n.t('default_text.content') }
  let(:checkbox_question) {  'What do you put in your coffee?'}
  let(:checkbox_question_answers) {['nothing, I like it black', 'milk', 'sugar', 'sweetener', 'syrup']}
  let(:radios_question) { 'Do you like marmite?'}
  let(:radios_question_answers) {['yes', 'no', 'never tried it']}
  let(:unsupported_question) { 'What is your name?'}
  let(:multiquestion_page_question) { 'What is your favourite cheese?'}
  let(:checkbox_operator_values) {['contains', 'does_not_contain', 'is_answered', 'is_not_answered']}
  let(:radio_operator_values) { ['is', 'is_not', 'is_answered', 'is_not_answered'] }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: fixture)
  end

  context 'adding conditonal content' do

    scenario 'to start page' do
      when_I_edit_the_page(title: 'Service name goes here')
      when_I_focus_editable_content(editor.page_body)
      then_I_should_not_see_the_conditional_content_menu_option
      when_I_focus_editable_content(editor.page_before_you_start)
      then_I_should_not_see_the_conditional_content_menu_option
    end

    scenario 'to multiple question page' do
      when_I_edit_the_page(title: 'Multiple')
      and_I_add_a_multiple_page_content_component
      when_I_want_to_edit_content_component_properties(editor.editable_content_areas.last)
      then_I_should_see_the_conditional_content_menu_option
      and_I_want_to_set_content_visibility
      then_I_should_see_the_conditional_content_modal
    end

    scenario 'to content pages' do
      when_I_edit_the_page(title: 'Conditional content')
      and_I_add_a_content_component(content: 'You will always see this content')
      when_I_want_to_edit_content_component_properties(editor.editable_content_areas.last)
      then_I_should_see_the_conditional_content_menu_option
      and_I_want_to_set_content_visibility
      then_I_should_see_the_conditional_content_modal
    end

    scenario 'to exit pages' do
      when_I_edit_the_page(title: 'Bye')
      when_I_want_to_edit_content_component_properties(editor.editable_content_areas.last)
      then_I_should_see_the_conditional_content_menu_option
      and_I_want_to_set_content_visibility
      then_I_should_see_the_conditional_content_modal
    end

    scenario 'to check your answers pages' do
      when_I_edit_the_page(title: 'Check your answers')
      and_I_add_a_content_component(content: 'You will always see this content')
      when_I_want_to_edit_content_component_properties(editor.editable_content_areas.last)
      then_I_should_see_the_conditional_content_menu_option
      and_I_want_to_set_content_visibility
      then_I_should_see_the_conditional_content_modal
    end

    scenario 'to confirmation page' do
      when_I_edit_the_page(title: 'Application complete')
      and_I_add_a_content_component(content: 'You will always see this content')
      when_I_want_to_edit_content_component_properties(editor.editable_content_areas.last)
      then_I_should_see_the_conditional_content_menu_option
      and_I_want_to_set_content_visibility
      then_I_should_see_the_conditional_content_modal
    end
  end

  context 'editing conditional content' do

    scenario 'setting to always display' do
      when_I_edit_the_page(title: 'Conditional content')
      and_I_add_a_content_component(content: 'You will always see this content')
      and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)

      then_the_display_radio_selected_is(I18n.t('conditional_content.display.always'))
      then_I_cannot_see_the_conditional_fields

      when_I_commit_my_changes

      then_the_component_config_includes(editor.last_editable_content_area, 'display' => 'always')
      then_I_cannot_see_the_show_if_button_for(editor.last_editable_content_area)
    end

    scenario 'setting to never display' do
      when_I_edit_the_page(title: 'Conditional content')
      and_I_add_a_content_component(content: 'You will never see this content')
      and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)

      then_the_display_radio_selected_is(I18n.t('conditional_content.display.always'))
      and_I_set_display_to_never
      then_I_cannot_see_the_conditional_fields

      when_I_commit_my_changes

      then_the_component_config_includes(editor.last_editable_content_area, 'display' => 'never')
      then_I_can_see_the_hidden_button_for(editor.last_editable_content_area)
    end

    scenario 'setting to conditionally display' do
      when_I_edit_the_page(title: 'Conditional content')
      and_I_add_a_content_component(content: 'You will maybe see this content')
      and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)

      then_the_display_radio_selected_is(I18n.t('conditional_content.display.always'))
      and_I_set_display_to_conditional
      then_I_should_see_the_conditionals(count: 1)

      editor.conditional_content_modal.conditionals.first.within do |conditional|
        conditional.expressions.first.within do |expression|
          when_I_select_a_component(expression, checkbox_question)

          then_I_can_see_the_expression_conditions(expression)
          and_the_operator_field_contains_the_options(expression, checkbox_operator_values)
          and_the_answer_field_contains_the_options(expression, checkbox_question_answers)

          and_I_select_an_operator(expression, 'is answered')
          then_I_should_not_see_the_answer_field(expression)
          and_I_select_an_operator(expression, 'contains')
          then_I_should_see_the_answer_field(expression)
          and_I_select_an_operator(expression, 'is not answered')
          then_I_should_not_see_the_answer_field(expression)

          when_I_select_a_component(expression, radios_question)

          then_I_can_see_the_expression_conditions(expression)
          and_the_operator_field_contains_the_options(expression, radio_operator_values)
          and_the_answer_field_contains_the_options(expression, radios_question_answers)

          and_I_select_an_operator(expression, 'is answered')
          then_I_should_not_see_the_answer_field(expression)
          and_I_select_an_operator(expression, 'is')
          then_I_should_see_the_answer_field(expression)
          and_I_select_an_operator(expression, 'is not answered')
          then_I_should_not_see_the_answer_field(expression)
        end
      end

      when_I_commit_my_changes

      then_the_component_config_includes(editor.last_editable_content_area, 'display' => 'conditional')
      then_the_component_config_has_key(editor.last_editable_content_area, 'conditionals' )
      then_I_can_see_the_show_if_button_for(editor.last_editable_content_area)
    end

    scenario 'loads state from component config' do
      when_I_edit_the_page(title: 'Conditional content')
      and_I_add_a_content_component(content: 'You will maybe see this content')
      and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)
      and_I_set_display_to_conditional

      editor.conditional_content_modal.conditionals.first.within do |conditional|
        conditional.expressions.first.within do |expression|
          when_I_select_a_component(expression, checkbox_question)
          and_I_select_an_operator(expression, 'does not contain')
          and_I_select_an_answer(expression, 'milk')
        end
      end

      when_I_commit_my_changes

      editor.show_if_button.click
      then_I_should_see_the_conditional_content_modal
      then_I_should_see_one_conditional

      editor.conditional_content_modal.conditionals.first.within do |conditional|
        conditional.expressions.first.within do |expression|
          then_the_expression_has_the_values(
            expression:,
            component: '1c3bc32c-46d3-4393-98eb-d35b4de50a4f',
            operator: 'does_not_contain',
            answer: '143ccfe3-33e6-4bd9-a548-ae9b42154f62'
          )
        end
      end
    end

    scenario 'adding and removing conditions and expressions' do
      when_I_edit_the_page(title: 'Conditional content')
      and_I_add_a_content_component(content: 'You will maybe see this content')
      and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)
      and_I_set_display_to_conditional

      then_I_should_see_one_conditional
      then_the_conditionals_cannot_be_deleted

      when_I_add_a_conditional

      then_I_should_see_two_conditionals
      then_the_conditionals_can_be_deleted

      editor.conditional_content_modal.conditionals.each do |conditional|
        then_I_should_see_one_expression(conditional)
        and_the_expressions_cannot_be_deleted(conditional)
        and_the_expressions_have_the_correct_label(conditional)

        when_I_add_another_expression(conditional)

        then_I_should_see_two_expressions(conditional)
        and_the_expressions_can_be_deleted(conditional)
        and_the_expressions_have_the_correct_label(conditional)

        when_I_delete_an_expression(conditional.expressions.first)

        then_I_should_see_one_expression(conditional)
        and_the_expressions_cannot_be_deleted(conditional)
        and_the_expressions_have_the_correct_label(conditional)
      end

      when_I_delete_a_conditional(editor.conditional_content_modal.conditionals.first)

      then_I_should_see_one_conditional
      then_the_conditionals_cannot_be_deleted
    end
  end

  context 'errors' do
    scenario 'when there is no question (component) selected' do
      when_I_edit_the_page(title: 'Conditional content')
      and_I_add_a_content_component(content: 'You will maybe see this content')
      and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)
      and_I_set_display_to_conditional

      when_I_commit_my_changes

      then_I_should_see_the_error_summary_with(I18n.t('activemodel.errors.messages.blank', attribute: 'Component'))
      then_the_component_field_should_be_in_error(editor.conditional_content_modal.conditional(0).expression(0))

      editor.conditional_content_modal.within do |modal|
        when_I_select_a_component(modal.conditional(0).expression(0), 'Do you like chocolate?')
      end

      when_I_commit_my_changes
      then_I_should_not_see_the_conditional_content_modal
    end

    scenario 'when an unsupported question (component) is selected' do
      when_I_edit_the_page(title: 'Conditional content')
      and_I_add_a_content_component(content: 'You will maybe see this content')
      and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)
      and_I_set_display_to_conditional

      editor.conditional_content_modal.within do |modal|
          expression = modal.first_conditional.first_expression

          when_I_select_a_component(expression, unsupported_question)
          then_I_should_see_the_unsupported_error(expression)

          when_I_select_a_component(expression, checkbox_question)
          then_I_should_not_see_the_unsupported_error(expression)

          when_I_select_a_component(expression, unsupported_question)
          then_I_should_see_the_unsupported_error(expression)
      end

      when_I_commit_my_changes

      then_I_should_see_the_error_summary_with(I18n.t('activemodel.errors.models.component_expression.unsupported'))
      then_the_component_field_should_be_in_error(editor.conditional_content_modal.first_conditional.first_expression)

      editor.conditional_content_modal.conditionals.first.within do |conditional|
        when_I_select_a_component(conditional.expressions.first, 'Do you like chocolate?')
      end

      when_I_commit_my_changes
      then_I_should_not_see_the_conditional_content_modal
    end

    scenario 'when a component (question) on the same page is selected' do
      when_I_edit_the_page(title: 'Multiple')
      and_I_add_a_multiquestion_page_content_component(content: 'You will maybe see this content')
      and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)
      and_I_set_display_to_conditional

      editor.conditional_content_modal.within do |modal|
          expression = modal.first_conditional.first_expression

          when_I_select_a_component(expression, multiquestion_page_question)
          then_I_should_see_the_same_page_error(expression)

          when_I_select_a_component(expression, checkbox_question)
          then_I_should_not_see_the_same_page_error(expression)

          when_I_select_a_component(expression, multiquestion_page_question)
          then_I_should_see_the_same_page_error(expression)
      end

      when_I_commit_my_changes

      then_I_should_see_the_error_summary_with(I18n.t('activemodel.errors.models.component_expression.same_page'))
      then_the_component_field_should_be_in_error(editor.conditional_content_modal.first_conditional.first_expression)

      editor.conditional_content_modal.conditionals.first.within do |conditional|
        when_I_select_a_component(conditional.expressions.first, 'Do you like chocolate?')
      end

      when_I_commit_my_changes
      then_I_should_not_see_the_conditional_content_modal
    end
  end
end


def when_I_edit_the_page(title:)
  page.find('.govuk-link', text: title).click
end

def and_I_add_a_multiquestion_page_content_component(content:)
    editor.add_a_component_button.click
    editor.content_component.click
    component = editor.editable_content_areas.last
    when_I_change_editable_content(component, content: content)
end

def then_I_should_not_see_the_conditional_content_menu_option
  expect(editor).to_not have_show_if_link
end

def then_I_should_see_the_conditional_content_menu_option
  expect(editor).to have_show_if_link
end

def and_I_want_to_set_content_visibility
    editor.show_if_link.click
end

def and_I_want_to_edit_content_visibility_for(component)
  when_I_want_to_edit_content_component_properties(component)
  then_I_should_see_the_conditional_content_menu_option
  and_I_want_to_set_content_visibility
  then_I_should_see_the_conditional_content_modal
end

def then_I_should_see_the_conditional_content_modal
  expect(editor).to have_conditional_content_modal
end

def then_I_should_not_see_the_conditional_content_modal
  expect(editor).not_to have_conditional_content_modal
end

def and_I_set_display_to_conditional
  editor.conditional_content_modal.display_conditional_radio.choose()
end

def and_I_set_display_to_never
  editor.conditional_content_modal.display_never_radio.choose()
end

def then_the_display_radio_selected_is(label)
  expect(editor.conditional_content_modal).to have_field(label, visible: :all, checked: true)
end

def then_I_cannot_see_the_conditional_fields
  expect(editor.conditional_content_modal).to have_conditionals_container(visible: :hidden)
end

def then_I_should_see_one_conditional
  then_I_should_see_the_conditionals(count: 1)
end

def then_I_should_see_two_conditionals
  then_I_should_see_the_conditionals(count: 2)
end

def then_I_should_see_the_conditionals(count:)
  expect(editor.conditional_content_modal).to have_conditionals(count: count)
end

def then_I_should_see_one_expression(conditional)
  then_I_should_see_the_expressions(conditional:, count: 1)
end

def then_I_should_see_two_expressions(conditional)
  then_I_should_see_the_expressions(conditional:, count: 2)
end

def then_I_should_see_the_expressions(conditional:, count:)
  expect(conditional).to have_expressions(count: count)
end

def then_the_component_config_includes(component, **inclusions)
  expect(JSON.parse(component['data-config'])).to include(inclusions)
end

def then_the_component_config_has_key(component, key)
  expect(JSON.parse(component['data-config'])).to include(key)
end

def then_I_cannot_see_the_show_if_button_for(component)
  expect(component).to have_no_button(I18n.t('conditional_content.show_if_button_label'))
end

def then_I_can_see_the_show_if_button_for(component)
  expect(component).to have_button(I18n.t('conditional_content.show_if_button_label'))
end

def then_I_can_see_the_hidden_button_for(component)
  expect(component).to have_button(I18n.t('conditional_content.hidden_button_label'))
end

def when_I_select_a_component(expression, label)
  expression.component_select.select(label)
  sleep(0.5)
end

def when_I_commit_my_changes
  editor.conditional_content_modal.update_button.click
  sleep(2)
end

def then_I_can_see_the_expression_conditions(expression)
  expect(expression).to have_operator_select
  expect(expression).to have_answer_select
end

def and_the_operator_field_contains_the_options(expression, values)
  expect(expression.operator_select_values).to eq values
end

def and_the_answer_field_contains_the_options(expression, labels)
  expect(expression.answer_select_labels).to eq labels
end

def and_I_select_an_operator(expression, text)
  expect(expression).to have_operator_select
  expression.operator_select.select(text)
end

def and_I_select_an_answer(expression, text)
  expect(expression).to have_answer_select
  expression.answer_select.select(text)
end

def then_the_expression_has_the_values(expression:, component:, operator:, answer: )
  expect(expression.component_select.value).to eq component
  expect(expression.operator_select.value).to eq operator
  expect(expression.answer_select.value).to eq answer
end

def when_I_add_a_conditional
  editor.conditional_content_modal.add_another_rule.click
end

def when_I_delete_a_conditional(conditional)
 conditional.delete_button.click
end

def then_the_expression_question_has_the_correct_label(expression,index)
  if index == 0
    expect(expression.question_label.text).to eq I18n.t('branches.expression.if')
  else
    expect(expression.question_label.text).to eq I18n.t('branches.expression.and')
  end
end

def then_the_conditionals_cannot_be_deleted
  editor.conditional_content_modal.conditionals.each do |conditional|
    expect(conditional).not_to have_delete_button
  end
end

def then_the_conditionals_can_be_deleted
  editor.conditional_content_modal.conditionals.each do |conditional|
    expect(conditional).to have_delete_button
  end
end

def and_the_expressions_cannot_be_deleted(conditional)
  conditional.expressions.each do |expression|
    expect(expression).not_to have_delete_button
  end
end

def and_the_expressions_can_be_deleted(conditional)
  conditional.expressions.each do |expression|
    expect(expression).to have_delete_button
  end
end

def and_the_expressions_have_the_correct_label(conditional)
  conditional.expressions.each_with_index do |expression, index|
    then_the_expression_question_has_the_correct_label(expression,index)
  end
end

def when_I_add_another_expression(conditional)
  conditional.add_condition.click
  sleep(0.5)
end

def when_I_delete_an_expression(expression)
  expression.delete_button.click
  sleep(0.5)
end

def then_I_should_see_the_error_summary_with(*messages)
  editor.conditional_content_modal.within do |modal|
    expect(modal).to have_error_summary
    expect(modal.error_summary).to have_error_summary_title
    messages.each do |message|
      expect(modal.error_summary).to have_text(message)
    end
  end
end

def then_the_component_field_should_be_in_error(expression)
  expect(expression.root_element['class']).to include 'error'
  expect(expression.component_select['class']).to include 'govuk-select--error'
end

def then_I_should_see_the_unsupported_error(expression)
    expect(expression).to have_unsupported_error
end

def then_I_should_not_see_the_unsupported_error(expression)
    expect(expression).not_to have_unsupported_error
end
def then_I_should_see_the_same_page_error(expression)
    expect(expression).to have_same_page_error
end

def then_I_should_not_see_the_same_page_error(expression)
    expect(expression).not_to have_same_page_error
end

def then_I_should_see_the_answer_field(expression)
  expect(expression).to have_answer_select
end

def then_I_should_not_see_the_answer_field(expression)
  expect(expression).not_to have_answer_select
end
