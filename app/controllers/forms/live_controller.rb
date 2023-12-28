class Forms::LiveController < ApplicationController
  after_action :verify_authorized
  def show_form
    authorize current_form, :can_view_form?
    render template: "live/show_form", locals: { form_metadata: current_form, form: current_live_form }
  end

  def show_pages
    authorize current_form, :can_view_form?
    render template: "live/show_pages", locals: { form: current_live_form }
  end
end
