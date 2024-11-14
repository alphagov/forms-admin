class Pages::SecondarySkipController < PagesController
  before_action :ensure_branch_routing_feature_enabled

  def new
    secondary_skip_input = Pages::SecondarySkipInput.new(form: current_form, page:)
    render locals: {
      secondary_skip_input:,
      back_link_url: show_routes_path(form_id: current_form.id, page_id: page.id),
    }
  end
private

  def ensure_branch_routing_feature_enabled
    raise ActionController::RoutingError, "branch_routing feature not enabled" unless Settings.features.branch_routing
  end
end
