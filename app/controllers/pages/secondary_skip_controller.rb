class Pages::SecondarySkipController < PagesController
  before_action :ensure_branch_routing_feature_enabled

  def new
    secondary_skip_input = Pages::SecondarySkipInput.new(form: current_form, page:)
    render locals: {
      secondary_skip_input:,
      back_link_url: show_routes_path(form_id: current_form.id, page_id: page.id),
    }
  end

  def create
    secondary_skip_input = Pages::SecondarySkipInput.new(secondary_skip_input_params)

    if secondary_skip_input.submit
      redirect_to show_routes_path(form_id: current_form.id, page_id: page.id)
    else
      render template: "pages/secondary_skip/new", locals: {
        secondary_skip_input:,
        back_link_url: show_routes_path(form_id: current_form.id, page_id: page.id),
      }, status: :unprocessable_entity
    end
  end

private

  def secondary_skip_input_params
    params.require(:pages_secondary_skip_input).permit(:routing_page_id, :goto_page_id).merge(form: current_form, page:)
  end

  def ensure_branch_routing_feature_enabled
    raise ActionController::RoutingError, "branch_routing feature not enabled" unless Settings.features.branch_routing
  end
end
