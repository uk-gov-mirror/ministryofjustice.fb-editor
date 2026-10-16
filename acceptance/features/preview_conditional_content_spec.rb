require_relative '../spec_helper'

feature 'Preview conditional content' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:optional_content) { I18n.t('default_text.content') }
  let(:always_content) { 'This content is always visible' }
  let(:never_content) { 'This content is never visible' }
  let(:component) { 'Do you like coffee?' }
  let(:component_2) { 'What do you put in your coffee?'}

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'conditional_content_preview_fixture')
  end

  shared_examples 'a conditional content page' do
    it 'previews conditional content' do
      when_I_add_content_that_always_displays(page_title:, content: always_content)

      then_when_I_preview_the_page(page_title:) do
        then_I_dont_see_the_conditional_content_notification
        then_I_see_the_always_content
      end

      when_I_add_content_that_never_displays(page_title:, content: never_content)

      then_when_I_preview_the_page(page_title:) do
        then_I_see_the_conditional_content_notification
        then_I_see_the_always_content
        then_I_see_the_never_content
      end

      when_I_edit_content_to_display_conditionally(page_title:, content: conditional_content) do
        and_I_set_the_conditions( conditions: )
      end

      then_when_I_preview_the_page(page_title:) do
        then_I_see_the_conditional_content_notification
        then_I_see_the_always_content
        then_I_see_the_conditional_content
      end

      when_I_add_content_that_never_displays(page_title:, content: never_content)

      preview_form = when_I_preview_the_form
      within_window(preview_form) do
        then_I_see_the_page_heading('Service name goes here')
        page.click_button 'Start now'

        then_I_see_the_page_heading('Do you like coffee?')

        if subject_page_type == 'exit'
          and_I_choose_the_answer('no')
          and_I_continue
          then_I_see_the_page_heading('Sorry')
          then_I_see_the_correct_content
        else
          and_I_choose_the_answer('yes')
          and_I_continue

          then_I_see_the_page_heading('What do you put in your coffee?')
          and_I_choose_the_answer('milk')
          and_I_continue
          then_I_see_the_page_heading('Extra')

          if subject_page_type == 'multiple_question'
            then_I_see_the_correct_content
          end

          and_I_continue
          then_I_see_the_page_heading('Summary')

          if subject_page_type == 'content'
            then_I_see_the_correct_content
          end

          and_I_continue
          then_I_see_the_page_heading('Check your answers')

          if subject_page_type == 'check_your_answers'
            then_I_see_the_correct_content
          end

          page.click_button 'Submit'
          then_I_see_the_page_heading('Application complete')

          if subject_page_type == 'confirmation'
            then_I_see_the_correct_content
          end
        end
      end
    end
  end

  context 'exit page' do
    let(:subject_page_type) { 'exit' }
    let(:page_title) { 'Sorry' }  
    let(:conditional_content) { 'You do not like coffee' }
    let(:conditions) do
      [
        [
          { 
            component:,
            operator: 'is',
            answer: 'no'
          }
        ]
      ]
    end

    it_behaves_like 'a conditional content page'
  end

  context 'multiple question page' do
    let(:subject_page_type) { 'multiple_question' }
    let(:page_title) { 'Extra' } 
    let(:conditional_content) { 'You do like coffee' }
    let(:conditions) do
      [
        [
          { 
            component:,
            operator: 'is',
            answer: 'yes'
          }
        ]
      ]
    end

    it_behaves_like 'a conditional content page'
  end

  context 'content page' do
    let(:subject_page_type) { 'content' }
    let(:page_title) { 'Summary' } 
    let(:conditional_content) { 'You like coffee and put milk in' }
    let(:conditions) do
      [
        [
          { 
            component:,
            operator: 'is',
            answer: 'yes'
          },
          {
            component: component_2,
            operator: 'contains',
            answer: 'milk'
          }
        ]
      ]
    end

    it_behaves_like 'a conditional content page'
  end

  context 'check your answers page' do
    let(:subject_page_type) { 'check_your_answers' }
    let(:page_title) { 'Check your answers' } 
    let(:conditional_content) { 'You like coffee with either milk or sugar' }
    let(:conditions) do
      [
        [
          { 
            component:,
            operator: 'is',
            answer: 'yes'
          },
          {
            component: component_2,
            operator: 'contains',
            answer: 'milk'
          }
        ],
        [
          { 
            component:,
            operator: 'is',
            answer: 'yes'
          },
          {
            component: component_2,
            operator: 'contains',
           answer: 'sugar'
          }
        ],
      ]
    end

    it_behaves_like 'a conditional content page'
  end

  context 'confirmation page' do
    let(:subject_page_type) { 'confirmation' }
    let(:page_title) { 'Application complete' } 
    let(:conditional_content) { 'You like coffee without sugar' }

    let(:conditions) do
      [
        [
          { 
            component:,
            operator: 'is',
            answer: 'yes'
          },
          {
            component: component_2,
            operator: 'does not contain',
            answer: 'sugar'
          }
        ]
      ]
    end

    it_behaves_like 'a conditional content page'
  end

end

def when_I_add_content_that_always_displays(page_title:, content:)
  when_I_edit_the_page(title: page_title)
  and_I_add_a_content_component(content: content)
  when_I_save_my_changes
  and_I_return_to_flow_page 
end

def when_I_add_content_that_never_displays(page_title:, content:)
  when_I_edit_the_page(title: page_title)
  and_I_add_a_content_component(content:)
  and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)
  and_I_set_display_to_never
  when_I_update_conditional_content
  when_I_save_my_changes
  and_I_return_to_flow_page 
end

def when_I_edit_content_to_display_conditionally(page_title:,content:)
  when_I_edit_the_page(title: page_title)
  when_I_change_editable_content(editor.last_editable_content_area, content:)
  and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)
  and_I_set_display_to_conditional
  yield if block_given?
  when_I_update_conditional_content
  when_I_save_my_changes
  and_I_return_to_flow_page 
end

def and_I_set_the_conditions(conditions: [])
  extra_conditionals = conditions.length - 1

  if(extra_conditionals > 0)
    extra_conditionals.times { click_button(I18n.t('conditional_content.add_another_rule')) }
  end

  conditions.each_with_index do |expressions_to_create, c_idx|
    editor.conditional_content_modal.conditional(c_idx).within do |conditional|

      extra_expressions = expressions_to_create.length - 1

      if(extra_expressions > 0)
        extra_expressions.times { click_button(I18n.t('conditional_content.add_condition')) }
      end

      expressions_to_create.each_with_index do |expression_to_create, e_idx|
        conditional.expression(e_idx).within do |expression|
          when_I_select_a_component(expression, expression_to_create[:component])
          and_I_select_an_operator(expression, expression_to_create[:operator])
          and_I_select_an_answer(expression, expression_to_create[:answer])
        end
      end
    end
  end
end

def when_I_edit_the_page(title:)
  page.find('.govuk-link', text: title).click 
end

def and_I_want_to_set_content_visibility
  editor.show_if_link.click 
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

def and_I_set_display_to_conditional
  editor.conditional_content_modal.display_conditional_radio.choose() 
end

def and_I_set_display_to_never
  editor.conditional_content_modal.display_never_radio.choose() 
end

def when_I_select_a_component(expression, label)
  expression.component_select.select(label)
  sleep(0.5)
end

def and_I_select_an_operator(expression, text)
  expression.operator_select.select(text)
end

def and_I_select_an_answer(expression, text)
  expression.answer_select.select(text)
end

def when_I_update_conditional_content
  editor.conditional_content_modal.update_button.click 
  sleep(0.5)
end

def then_when_I_preview_the_page(page_title:)
  preview_page = when_I_preview_the_page(page_title) 
  within_window( preview_page ) do
    yield if block_given?
  end
end

def then_I_see_the_page_heading(title)
  expect(page).to have_content(title)
end

def then_I_see_the_correct_content
  then_I_see_the_always_content
  then_I_dont_see_the_never_content
  then_I_see_the_conditional_content
  then_I_dont_see_the_conditional_content_notification
end

def then_I_see_the_always_content 
  expect(page).to have_content always_content
end

def then_I_see_the_never_content
  expect(page).to have_content never_content
end

def then_I_dont_see_the_never_content
  expect(page).to have_no_content never_content
end

def then_I_see_the_conditional_content
  expect(page).to have_content conditional_content
end

def then_I_dont_see_the_conditional_content_notification
  expect(page).to have_no_content I18n.t('presenter.conditional_content.notification')
end

def then_I_see_the_conditional_content_notification
  expect(page).to have_content I18n.t('presenter.conditional_content.notification')
end

def and_I_continue
  page.click_button 'Continue'
end

def and_I_choose_the_answer(answer)
  find('label', text: answer).click
end
