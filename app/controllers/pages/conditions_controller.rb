class Pages::ConditionsController < PagesController
  before_action :can_add_page_routing, only: %i[routing_page new create]
  before_action :can_edit_page_routing, only: %i[edit update]
  before_action :can_delete_page_routing, only: %i[delete destroy]

  def routing_page
    render template: "pages/conditions/routing_page", locals: { form: @form }
  end

  def set_routing_page
    routing_page = Page.find(params[:form][:routing_page_id], params: { form_id: @form.id })
    redirect_to new_condition_path(@form, routing_page)
  end

  def new
    condition_form = Pages::ConditionsForm.new(form: @form, page:)
    render template: "pages/conditions/new", locals: { condition_form: }
  end

  def create
    condition_form = Pages::ConditionsForm.new(condition_form_params)

    if condition_form.submit
      redirect_to form_pages_path(@form), success: t("banner.success.route_created", question_position: condition_form.page.position)
    else
      render template: "pages/conditions/new", locals: { condition_form: }, status: :unprocessable_entity
    end
  end

  def edit
    condition = Condition.find(params[:condition_id], params: { form_id: @form.id, page_id: page.id })

    condition_form = Pages::ConditionsForm.new(form: @form, page:, record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id)

    condition_form.check_errors_from_api

    render template: "pages/conditions/edit", locals: { condition_form: }
  end

  def update
    condition = Condition.find(params[:condition_id], params: { form_id: @form.id, page_id: page.id })

    form_params = condition_form_params.merge(record: condition)

    condition_form = Pages::ConditionsForm.new(form_params)

    if condition_form.update
      redirect_to form_pages_path(@form)
    else
      render template: "pages/conditions/edit", locals: { condition_form: }, status: :unprocessable_entity
    end
  end

  def delete
    condition = Condition.find(params[:condition_id], params: { form_id: @form.id, page_id: page.id })

    delete_condition_form = Pages::DeleteConditionForm.new(form: @form, page:, record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id)

    render template: "pages/conditions/delete", locals: { delete_condition_form: }
  end

  def destroy
    condition = Condition.find(params[:condition_id], params: { form_id: @form.id, page_id: page.id })

    form_params = delete_condition_form_params.merge(record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id)

    delete_condition_form = Pages::DeleteConditionForm.new(form_params)

    if delete_condition_form.delete
      case delete_condition_form.confirm_deletion
      when "true"
        redirect_to form_pages_path(@form.id, page.id)
      when "false"
        redirect_to edit_condition_path(@form.id, page.id, condition.id)
      end
    else
      render template: "pages/conditions/delete", locals: { delete_condition_form: }, status: :unprocessable_entity
    end
  end

private

  def can_add_page_routing
    authorize @form, :can_add_page_routing_conditions?
  end

  def can_edit_page_routing
    authorize @form, :can_edit_page_routing_conditions?
  end

  def can_delete_page_routing
    authorize @form, :can_delete_page_routing_conditions?
  end

  def condition_form_params
    params.require(:pages_conditions_form).permit(:answer_value, :goto_page_id).merge(form: @form, page:)
  end

  def delete_condition_form_params
    params.require(:pages_delete_condition_form).permit(:answer_value, :goto_page_id, :confirm_deletion).merge(form: @form, page:)
  end
end
