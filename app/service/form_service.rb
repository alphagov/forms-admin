class FormService
  include Rails.application.routes.url_helpers

  def initialize(form)
    @form = form
  end

  def path_for_state
    return live_form_path(@form.id) if @form.is_live?
    return archived_form_path(@form.id) if @form.is_archived?

    form_path(@form.id)
  end
end
