module MultipleQuestionsPageHelper
  def given_I_have_a_multiple_questions_page
    given_I_add_a_multiple_question_page
    and_I_add_a_page_url(url)
    when_I_add_the_page
  end

  def and_I_add_the_component(component)
    and_I_add_a_component
    and_I_add_a_question
    questions_before = all('.Question').count
    find(:link, component).click
    # adding a component reloads the page, so wait for the new question
    expect(page).to have_css('.Question', count: questions_before + 1)
  end

  def and_I_add_a_multiple_page_content_component
    sleep 2
    editor.add_a_component_button.click
    and_I_add_a_content_area
  end

  def and_I_add_a_component
    editor.add_a_component_button.click
  end

  def and_I_add_a_question
    editor.question_component.hover
  end

  def and_I_add_a_content_area
    editor.content_component.click
  end

  def and_I_update_the_components
    and_I_change_the_page_heading(page_heading)
    and_I_change_the_text_component(text_component_question)
    and_I_change_the_email_component(email_component_question)
    and_I_change_the_textarea_component(textarea_component_question)
    and_I_change_the_radio_component(
      radio_component_question,
      options: radio_component_options
    )
    and_I_change_the_checkboxes_component(
      checkboxes_component_question,
      options: checkboxes_component_options
    )
    and_I_change_the_address_component(address_component_question)
  end

  def and_I_change_the_text_component(question, component: 0)
    and_I_change_the_component(question, component: component, tag: 'label')
  end

  def and_I_change_the_textarea_component(question, component: 1)
    and_I_change_the_component(question, component: component, tag: 'label')
  end

  def and_I_change_the_email_component(question, component: 2)
    and_I_change_the_component(question, component: component, tag: 'label')
  end

  def and_I_change_the_radio_component(question, component: 3, options:)
    and_I_change_the_component(question, component: component, tag: 'legend', options: options)
  end

  def and_I_change_the_checkboxes_component(question, component: 4, options:)
    and_I_change_the_component(question, component: component, tag: 'legend', options: options)
  end

  def and_I_change_the_address_component(question, component: 5)
    and_I_change_the_component(question, component: component, tag: 'legend')
  end

  def and_I_change_the_component(question, component:, tag:, options: nil)
    element = editor.find(
      :xpath,
      "//*[@data-fb-content-id='page[components][#{component}]']")
    question_name = element.find("#{tag} .EditableElement")
    question_name.set(question)

    if options
      options.each_with_index do |option, index|
        element.all('label')[index].set(option)
      end
    end
  end

  def and_I_want_to_delete_a_component(question)
    and_I_click_the_delete_link
    expect(editor.find(:css, '.component-dialog h3').text).to include(question)
    and_I_click_the_delete_button
  end

  def and_I_want_to_delete_a_branching_component(question)
    and_I_click_the_delete_link
    expect(
      editor.find(:css, '.component-dialog p').text
    ).to eq(I18n.t('questions.delete_modal.delete_question_used_for_branching_message'))
    editor.find(:css, '.ui-dialog-titlebar-close').click
  end

  def and_I_want_to_delete_a_content_component
    and_I_click_the_delete_link
    expect(
      editor.find(:css, '#dialog-confirmation-delete h3').text
    ).to eq(I18n.t('content.dialog.heading_remove'))
    and_I_click_the_delete_button
  end

  def and_I_click_the_delete_link
    editor.find('span', text: I18n.t('question.menu.remove')).click
  end

  def and_I_click_the_delete_button
    editor.find('button', text: I18n.t('dialogs.button_delete_component')).click
  end
end
