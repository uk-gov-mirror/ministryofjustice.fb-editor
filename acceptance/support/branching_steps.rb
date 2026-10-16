module BranchingSteps
  # Branching page set up
  def then_I_can_add_conditionals_and_expressions
    and_I_add_another_condition
    then_I_should_see_the_operator(I18n.t('branches.expression.and'))
    then_I_should_see_another_question_list
    then_I_should_see_multiple_delete_condition_buttons
  end

  def then_I_can_delete_conditionals_and_expressions
    and_I_delete_the_last_condition
    then_I_should_not_see_the_operator(I18n.t('branches.expression.and'))
    then_I_should_not_see_text(I18n.t('branches.condition_remove'))

    and_I_add_another_branch
    then_I_should_see_the_branch_title(index: 1, title: 'Branch 2')

    and_I_delete_the_branch(1)
    expect( editor.branches ).to have_conditionals(count: 1)
  end

  def when_I_update_the_question_name(question_name)
    editor.question_heading.first.set(question_name)
    when_I_save_my_changes
  end

  def and_I_edit_the_option_items(*item)
    editor.editable_options.first.set(item[0])
    editor.service_name.click
    editor.editable_options.last.set(item[1])
    editor.service_name.click
    when_I_save_my_changes
  end

  def and_I_want_to_add_branching(url)
    editor.connection_menu(url).click
    and_I_add_branching_to_the_page
    then_I_should_see_the_branching_page
  end

  def and_I_add_branching_to_the_page
    editor.branching_link.click
  end

  def then_I_should_see_the_branching_page
    expect(editor.page_heading.text).to eq(
      I18n.t('default_values.branching_title', branching_number: 1)
    )
  end

  def and_I_select_the_destination_page_dropdown
    editor.destination_options.click
  end

  def then_I_should_not_see_unconnected_pages
    expect(editor).to have_no_selector('.branch-optgroup')
  end

  def then_I_should_have_unconnected_pages
    expect(editor.find('#branch_default_next .branch-optgroup').visible?).to be_truthy
  end

  def then_I_should_see_the_correct_number_of_options(id, amount)
    options = find(id).all('option')
    expect(options.length).to eq(amount)
  end

  def then_I_should_not_see_field_options(name)
    expect(page).to have_no_select(name)
  end

  def then_I_should_see_the_field_option(name, text)
    expect(page).to have_select(name, text: text)
  end

  def and_I_choose_an_option(name, option)
    select(option, from: name)
  end

  def and_I_select_the_condition_dropdown
    editor.conditional_options.click
  end

  def then_I_should_see_statement_answers
    expect(editor).to have_operator_options
    expect(editor).to have_field_options
  end

  def and_I_select_the_field_dropdown
    editor.field_options.click
  end

  def and_I_select_the_operator_dropdown
    editor.operator_options.click
  end

  def and_I_select_the_otherwise_dropdown
    editor.otherwise_options.click
  end

  def then_I_should_see_no_errors
    expect(page).to have_no_selector('.govuk-error-summary')
  end

  def then_I_should_be_on_the_correct_branch_page(path)
    expect(URI(current_url).path.split('/').last).to eq(path)
  end

  def and_I_add_another_condition
    editor.add_condition.click
  end

  def and_I_delete_the_last_condition
    editor.last_condition_remover.click
    within('.Dialog') do
      editor.remove_condition_button.click
    end
  end

  def and_I_add_another_branch
    editor.add_another_branch.click
  end

  def and_I_delete_the_branch(index)
    editor.branches.conditional(index).delete_button.click
    within('.Dialog') do
      editor.remove_branch_button.click
    end
  end

  def then_I_should_see_the_operator(text)
    page_with_css('.expression [data-expression-target="label"]', text)
  end

  def page_with_css(element, text)
    expect(page).to have_css(element, text: text)
  end

  def page_without_css(element, text)
    expect(page).to have_no_css(element, text: text)
  end

  def then_I_should_see_another_question_list
    then_I_should_see_text(I18n.t('branches.expression.and'))
    then_I_should_see_text(I18n.t('branches.select_question'))
  end

  def then_I_should_not_see_text(text)
    expect(page).not_to have_text(text)
  end

  def then_I_should_see_text(text)
    expect(page).to have_text(text)
  end

  def then_I_should_see_the_add_condition_link
    expect(page).to have_content(I18n.t('branches.condition_add'))
  end

  def then_I_should_see_multiple_delete_condition_buttons
    expect(page).to have_css("button.expression__remover", :minimum => 2)
  end

  def then_I_should_not_see_the_operator(text)
    page_without_css('div.question label.govuk-label', text)
  end

  def then_I_should_see_the_branch_title(index:, title:)
    expect(editor.branches.conditional(index).title).to have_text(title)
  end

  def then_I_should_see_the_previous_page_title(page_title)
    expect(editor).to have_text(page_title)
  end

  # Error summary #
  def then_I_should_not_see_an_error_summary
    expect(page).to have_no_selector('.govuk-error-summary')
  end
end
