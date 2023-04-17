class Pages::ConditionsController < PagesController
  def routing_page
    render template: "pages/conditions/routing_page", locals: { form: @form }
  end

  def set_routing_page
    routing_page = Page.find(params[:form][:routing_page_id], params: { form_id: @form.id })
    redirect_to new_condition_path(@form, routing_page)
  end

  def new
    render template: "pages/conditions/new", locals: { form: @form, page: }
  end
end
