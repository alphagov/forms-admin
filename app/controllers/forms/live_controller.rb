class Forms::LiveController < Forms::BaseController
  def show_form
    render template: "live/show_form", locals: { form: current_form }
  end
end
