class Pages::AdditionalGuidanceController < PagesController
  def new
    additional_guidance_form = Pages::AdditionalGuidanceForm.new
    render "pages/additional_guidance", locals: { form: @form, page: @page, additional_guidance_form: }
  end
end
