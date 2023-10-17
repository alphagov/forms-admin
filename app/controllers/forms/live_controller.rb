class Forms::LiveController < Forms::BaseController
  after_action :verify_authorized
  def show_form
    authorize current_form, :can_view_form?
    render template: "live/show_form", locals: { form_metadata: current_form, form: current_live_form }
  end

  def show_pages
    authorize current_form, :can_view_form?
    render template: "live/show_pages", locals: { form: current_live_form }
  end

private

  def current_live_form
    Form.find_live(params[:form_id])
  end
end
