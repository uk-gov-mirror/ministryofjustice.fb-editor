module CommonSteps
  def given_I_have_a_service
    editor.load
    editor.name_field.set(another_service_name)
    editor.create_service_button.click
  end
  alias given_I_have_another_service given_I_have_a_service
end
