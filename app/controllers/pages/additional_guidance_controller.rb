class Pages::AdditionalGuidanceController < PagesController
  def new
    render "pages/additional_guidance", locals: { form: @form, page: @page }
  end
end
