module MultipleQuestionsPageHelper
  def given_I_have_a_multiple_questions_page
    given_I_add_a_multiple_question_page
    and_I_add_a_page_url(url)
    when_I_add_the_page
  end

  def and_I_add_a_text_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_text.click
  end

  def and_I_add_a_multiple_page_content_component
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

  def and_I_add_a_textarea_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_text_area.click
  end

  def and_I_add_a_radio_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_radio.click
  end

  def and_I_add_a_checkbox_component
    and_I_add_a_component
    and_I_add_a_question
    editor.add_checkboxes.click
  end

  def and_I_update_the_components
    and_I_change_the_page_heading(page_heading)
    and_I_change_the_text_component(text_component_question)
    and_I_change_the_textarea_component(textarea_component_question)
    and_I_change_the_radio_component(
      radio_component_question,
      options: radio_component_options
    )
    and_I_change_the_checkboxes_component(
      checkboxes_component_question,
      options: checkboxes_component_options
    )
  end

  def and_I_change_the_text_component(question, component: 0)
    and_I_change_the_component(question, component: component, tag: 'label')
  end

  def and_I_change_the_textarea_component(question, component: 1)
    and_I_change_the_component(question, component: component, tag: 'label')
  end

  def and_I_change_the_radio_component(question, component: 2, options:)
    and_I_change_the_component(question, component: component, tag: 'legend', options: options)
  end

  def and_I_change_the_checkboxes_component(question, component: 3, options:)
    and_I_change_the_component(question, component: component, tag: 'legend', options: options)
  end

  def and_I_change_the_component(question, component:, tag:, options: nil)
    element = editor.find(
      :xpath,
      "//*[@data-fb-content-id='page[components[#{component}]]']")
    question_name = element.find("#{tag} .EditableElement")
    question_name.set(question)

    if options
      options.each_with_index do |option, index|
        element.all('label')[index].set(option)
      end
    end
  end
end
