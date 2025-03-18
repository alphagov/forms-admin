class Pages::RoutesController < PagesController
  def show
    back_link_url = form_pages_path(current_form.id)
    pages = FormRepository.pages(current_form)
    routes = PageRoutesService.new(form: current_form, pages:, page:).routes
    errors = routes.flat_map { |route| route.validation_errors.map { |validation_error| error_construct(route: route, validation_error: validation_error) } }
    # to be eligible for route question has to have one question after it, so should always have next_page
    next_page = pages.find(proc { raise "Cannot find page with id #{page.next_page.inspect}" }) { _1.id == page.next_page }

    render locals: { current_form:, page:, pages:, next_page:, routes:, back_link_url:, errors: }
  end

  def delete
    @delete_confirmation_input = Pages::Routes::DeleteConfirmationInput.new
    render locals: { current_form:, page:, delete_confirmation_input: @delete_confirmation_input }
  end

  def destroy
    @delete_confirmation_input = Pages::Routes::DeleteConfirmationInput.new(delete_confirmation_input_params)

    if @delete_confirmation_input.submit
      if @delete_confirmation_input.confirmed?
        return redirect_to form_pages_path, success: t("banner.success.page_routes_deleted", question_number: current_form.page_number(page))
      end
    else
      return render :delete, locals: { current_form:, page:, delete_confirmation_input: @delete_confirmation_input }, status: :unprocessable_entity
    end

    redirect_to show_routes_path(form_id: current_form.id, page_id: page.id)
  end

private

  def delete_confirmation_input_params
    params.require(:pages_routes_delete_confirmation_input).permit(:confirm).merge(form: current_form, page: page)
  end

  def error_construct(route:, validation_error:)
    case validation_error.name
    when "answer_value_doesnt_exist"
      OpenStruct.new(link: "#check-#{route.id}", message: I18n.t("page_route_card.errors.answer_value_doesnt_exist"))
    when "cannot_route_to_next_page"
      if route.secondary_skip?
        OpenStruct.new(link: "#goto-#{route.id}", message: I18n.t("page_route_card.errors.cannot_route_to_next_page_secondary_skip"))
      else
        OpenStruct.new(link: "#goto-#{route.id}", message: I18n.t("page_route_card.errors.cannot_route_to_next_page"))
      end
    when "cannot_have_goto_page_before_routing_page"
      if route.secondary_skip?
        OpenStruct.new(link: "#goto-#{route.id}", message: I18n.t("page_route_card.errors.cannot_have_goto_page_before_routing_page_secondary_skip"))
      else
        OpenStruct.new(link: "#goto-#{route.id}", message: I18n.t("page_route_card.errors.cannot_have_goto_page_before_routing_page", question_number: question_number(route.check_page_id)))
      end
    end
  end

  def question_number(page_id)
    current_form.pages.find { |page| page.id == page_id }.position
  end
end
