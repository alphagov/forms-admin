class Forms::LiveController < Forms::BaseController
  def show_form
    render template: "live/show_form", locals: { form_metadata: form, form: current_live_form }
  end

  def show_pages
    render template: "live/show_pages", locals: { form: current_live_form }
  end

private

  def form
    Form.find(params[:form_id])
  end

  def current_live_form
    Form.find_live(params[:form_id])
  end
end
