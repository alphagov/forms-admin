class Forms::LiveController < Forms::BaseController
  after_action :verify_authorized
  def show_form
    authorize current_form, :can_view_form?
    render template: "live/show_form", locals: { form_metadata: current_form, form: current_live_form, metrics_data: }
  end

  def show_pages
    authorize current_form, :can_view_form?
    render template: "live/show_pages", locals: { form: current_live_form }
  end

private

  def current_live_form
    Form.find_live(params[:form_id])
  end

  def metrics_data
    today = Time.zone.today
    form_is_new = (today.to_date - Time.zone.parse(current_form.live_at).to_date).to_i < 1
    # TODO: fetch real data from CloudWatch
    weekly_submissions = 1025

    {
      weekly_submissions:,
      form_is_new:,
    }
  end
end
