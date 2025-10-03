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
    pages = form.pages
    page_routes = PageRoutesService.new(form:, pages:, page:).routes
    page_routes.each(&:destroy_and_update_form!)
  end
end
