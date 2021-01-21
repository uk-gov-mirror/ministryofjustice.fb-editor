module CommonSteps
  def given_I_have_a_service(service = service_name)
    editor.load
    given_I_want_to_create_a_service
    given_I_add_a_service(service)
    when_I_create_the_service
  end
  alias when_I_try_to_create_a_service_with_the_same_name given_I_have_a_service

  def given_I_have_another_service
    given_I_have_a_service(another_service_name)
  end

  def given_I_add_a_service(service = service_name)
    editor.name_field.set(service)
  end

  def given_I_want_to_create_a_service
    editor.create_service_button.click
  end

  def when_I_create_the_service
    editor.modal_create_service_button.click
  end
end
