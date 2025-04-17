class Pages::ExitPageController < PagesController
  before_action :can_add_page_routing, only: %i[new create]
  before_action :ensure_exit_pages_enabled

  def new
    exit_page_input = Pages::ExitPageInput.new(form: current_form, page:, answer_value: params[:answer_value])

    render template: "pages/exit_page/new", locals: { exit_page_input: }
  end

  def create
    exit_page_input = Pages::ExitPageInput.new(exit_page_input_params)

    if exit_page_input.submit
      # TODO: Route number is hardcoded whilst we can only have one value for it
      redirect_to show_routes_path(form_id: current_form.id, page_id: page.id), success: t("banner.success.exit_page_created")
    else
      render template: "pages/exit_page/new", locals: { exit_page_input: }, status: :unprocessable_entity
    end
  end

private

  def can_add_page_routing
    authorize current_form, :can_add_page_routing_conditions?
  end

  def ensure_exit_pages_enabled
    raise ActionController::RoutingError, "exit_pages feature not enabled" unless FeatureService.new(group: current_form.group).enabled?(:exit_pages)
  end

  def exit_page_input_params
    params.require(:pages_exit_page_input).permit(:exit_page_heading, :exit_page_markdown, :answer_value).merge(form: current_form, page:)
  end
end
