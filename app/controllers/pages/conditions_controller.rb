class Pages::ConditionsController < PagesController
  before_action :can_add_page_routing, only: %i[new create]

  def routing_page
    routing_page_input = Pages::RoutingPageInput.new(routing_page_id: params[:routing_page_id])
    render template: "pages/conditions/routing_page", locals: { form: current_form, routing_page_input: }
  end

  def set_routing_page
    routing_page_id = params[:pages_routing_page_input][:routing_page_id]
    routing_page_input = Pages::RoutingPageInput.new(routing_page_id:)

    if routing_page_input.valid?
      routing_page = Page.find(routing_page_id, params: { form_id: current_form.id })
      redirect_to new_condition_path(current_form, routing_page)
    else
      render template: "pages/conditions/routing_page", locals: { form: current_form, routing_page_input: }, status: :unprocessable_entity
    end
  end

  def new
    condition_input = Pages::ConditionsInput.new(form: current_form, page:)
    render template: "pages/conditions/new", locals: { condition_input: }
  end

  def create
    condition_input = Pages::ConditionsInput.new(condition_input_params)

    if condition_input.submit
      redirect_to form_pages_path(current_form), success: t("banner.success.route_created", question_position: condition_input.page.position)
    else
      render template: "pages/conditions/new", locals: { condition_input: }, status: :unprocessable_entity
    end
  end

  def edit
    condition = ConditionRepository.find(condition_id: params[:condition_id], form_id: current_form.id, page_id: page.id)

    condition_input = Pages::ConditionsInput.new(form: current_form, page:, record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id, skip_to_end: condition.skip_to_end).assign_condition_values

    condition_input.check_errors_from_api

    render template: "pages/conditions/edit", locals: { condition_input: }
  end

  def update
    condition = ConditionRepository.find(condition_id: params[:condition_id], form_id: current_form.id, page_id: page.id)

    form_params = condition_input_params.merge(record: condition)

    condition_input = Pages::ConditionsInput.new(form_params)

    if condition_input.update_condition
      redirect_to form_pages_path(current_form), success: t("banner.success.route_updated", question_position: condition_input.page.position)
    else
      render template: "pages/conditions/edit", locals: { condition_input: }, status: :unprocessable_entity
    end
  end

  def delete
    condition = ConditionRepository.find(condition_id: params[:condition_id], form_id: current_form.id, page_id: page.id)

    delete_condition_input = Pages::DeleteConditionInput.new(form: current_form, page:, record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id)

    render template: "pages/conditions/delete", locals: { delete_condition_input: }
  end

  def destroy
    condition = ConditionRepository.find(condition_id: params[:condition_id], form_id: current_form.id, page_id: page.id)

    form_params = delete_condition_input_params.merge(record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id)

    delete_condition_input = Pages::DeleteConditionInput.new(form_params)

    if delete_condition_input.submit
      if delete_condition_input.confirmed?
        redirect_to form_pages_path(current_form.id, page.id), success: t("banner.success.route_deleted", question_position: delete_condition_input.page.position)
      else
        redirect_to edit_condition_path(current_form.id, page.id, condition.id)
      end
    else
      render template: "pages/conditions/delete", locals: { delete_condition_input: }, status: :unprocessable_entity
    end
  end

private

  def can_add_page_routing
    authorize current_form, :can_add_page_routing_conditions?
  end

  def condition_input_params
    params.require(:pages_conditions_input).permit(:answer_value, :goto_page_id).merge(form: current_form, page:)
  end

  def delete_condition_input_params
    params.require(:pages_delete_condition_input).permit(:answer_value, :goto_page_id, :confirm).merge(form: current_form, page:)
  end
end
