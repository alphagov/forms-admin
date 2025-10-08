class Pages::Routes::DeleteConfirmationInput < ConfirmActionInput
  attr_accessor :form, :page

  def submit
    return false if invalid?

    if confirmed?
      delete_routes
    end

    true
  end

  def to_partial_path
    "input_objects/pages/routes/delete_confirmation_input"
  end

private

  def delete_routes
    page.check_conditions.each(&:destroy_and_update_form!)
  end
end
