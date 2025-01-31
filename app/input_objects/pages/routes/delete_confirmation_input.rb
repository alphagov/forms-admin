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
    pages = FormRepository.pages(form)
    page_routes = PageRoutesService.new(form:, pages:, page:).routes
    page_routes.each do |rc|
      rc.prefix_options[:form_id] = form.id
      rc.prefix_options[:page_id] = rc.routing_page_id
      ConditionRepository.destroy(rc)
    end
  end
end
