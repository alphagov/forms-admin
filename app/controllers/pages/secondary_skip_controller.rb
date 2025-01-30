class Pages::SecondarySkipController < PagesController
  before_action :ensure_branch_routing_feature_enabled, :ensure_page_has_skip_condition
  before_action :ensure_secondary_skip_blank, only: %i[new create]
  before_action :ensure_secondary_skip_exists, only: %i[edit update delete destroy]

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

  def edit
    secondary_skip_input = Pages::SecondarySkipInput.new(form: current_form, page:, record: secondary_skip_condition).assign_values

    render template: "pages/secondary_skip/edit", locals: {
      secondary_skip_input:,
      back_link_url: show_routes_path(form_id: current_form.id, page_id: page.id),
    }
  end

  def update
    secondary_skip_input = Pages::SecondarySkipInput.new(secondary_skip_input_params.merge(record: secondary_skip_condition))

    if secondary_skip_input.submit
      redirect_to show_routes_path(form_id: current_form.id, page_id: page.id)
    else
      render template: "pages/secondary_skip/edit", locals: {
        secondary_skip_input:,
        back_link_url: show_routes_path(form_id: current_form.id, page_id: page.id),
      }, status: :unprocessable_entity
    end
  end

  def delete
    delete_secondary_skip_input = Pages::DeleteSecondarySkipInput.new(form: current_form, page:, record: secondary_skip_condition)

    render template: "pages/secondary_skip/delete", locals: {
      delete_secondary_skip_input:,
      back_link_url: show_routes_path(form_id: current_form.id, page_id: page.id),
    }
  end

  def destroy
    delete_secondary_skip_input = Pages::DeleteSecondarySkipInput.new(delete_secondary_skip_input_params.merge(record: secondary_skip_condition))

    if delete_secondary_skip_input.submit
      redirect_to show_routes_path(form_id: current_form.id, page_id: page.id)
    else
      render template: "pages/secondary_skip/delete", locals: {
        delete_secondary_skip_input:,
        back_link_url: show_routes_path(form_id: current_form.id, page_id: page.id),
      }, status: :unprocessable_entity
    end
  end

private

  def secondary_skip_input_params
    params.require(:pages_secondary_skip_input).permit(:routing_page_id, :goto_page_id).merge(form: current_form, page:)
  end

  def delete_secondary_skip_input_params
    params.require(:pages_delete_secondary_skip_input).permit(:confirm).merge(form: current_form, page:)
  end

  def ensure_branch_routing_feature_enabled
    raise ActionController::RoutingError, "branch_routing feature not enabled" unless FeatureService.new(group: current_form.group).enabled?(:branch_routing)
  end

  def ensure_page_has_skip_condition
    unless page.routing_conditions.any? { |c| c.answer_value.present? }
      redirect_to form_pages_path(current_form.id)
    end
  end

  def ensure_secondary_skip_exists
    redirect_to show_routes_path(form_id: current_form.id, page_id: page.id) if secondary_skip_condition.blank?
  end

  def ensure_secondary_skip_blank
    redirect_to show_routes_path(form_id: current_form.id, page_id: page.id) if secondary_skip_condition.present?
  end

  def secondary_skip_condition
    @secondary_skip_condition ||= FormRepository.pages(current_form).flat_map(&:routing_conditions).compact_blank.find { |c| c.secondary_skip? && c.check_page_id == page.id }
  end
end
