class Pages::RoutesController < PagesController
  def show
    back_link_url = form_pages_path(current_form.id)
    render locals: { current_form:, page:, pages: current_form.pages, back_link_url: }
  end
end
