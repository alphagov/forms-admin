class Pages::ConditionsController < PagesController
  before_action :can_add_page_routing
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
      redirect_to form_pages_path(@form)
    else
      render template: "pages/conditions/new", locals: { condition_form: }, status: :unprocessable_entity
    end
  end

  def edit
    condition = Condition.find(params[:condition_id], params: { form_id: @form.id, page_id: page.id })

    condition_form = Pages::ConditionsForm.new(form: @form, page:, record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id)

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

    condition_form = Pages::ConditionsForm.new(form: @form, page:, record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id)

    render template: "pages/conditions/delete", locals: { condition_form: }
  end

  def destroy
    condition = Condition.find(params[:condition_id], params: { form_id: @form.id, page_id: page.id })

    case condition_form_params[:confirm_deletion]
    when "false"
      redirect_to edit_condition_path(@form.id, page.id, params[:condition_id])
    when "true"
      if condition.destroy
        redirect_to form_pages_path(@form.id, page.id)
      else
        raise StandardError, "Deletion unsuccessful"
      end
    else
      raise StandardError, "Deletion unsuccessful"
    end
  rescue StandardError
    condition_form = Pages::ConditionsForm.new(form: @form, page:, record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id)

    render template: "pages/conditions/delete", locals: { condition_form: }, status: :unprocessable_entity
  end

private

  def can_add_page_routing
    authorize @form, :can_add_page_routing_conditions?
  end

  def condition_form_params
    params.require(:pages_conditions_form).permit(:answer_value, :goto_page_id, :confirm_deletion).merge(form: @form, page:)
  end
end
