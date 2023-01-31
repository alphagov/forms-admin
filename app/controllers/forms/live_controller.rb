class Forms::LiveController < Forms::BaseController
  def show_form
    render template: "live/show_form", locals: { form: current_form }
  end

  def show_pages
    render template: "live/show_pages", locals: { form: current_form, pages: current_form.pages }
  end
end
