require "govuk_forms_markdown"

class Pages::AdditionalGuidanceController < PagesController
  def new
    additional_guidance_form = Pages::AdditionalGuidanceForm.new
    render "pages/additional_guidance", locals: { form: @form, page: @page, additional_guidance_form:, preview_html: nil }
  end

  def create
    additional_guidance_form = Pages::AdditionalGuidanceForm.new(additional_guidance_form_params)
    preview_html = GovukFormsMarkdown.render(additional_guidance_form.additional_guidance_markdown)

    render "pages/additional_guidance", locals: { form: @form, page: @page, additional_guidance_form:, preview_html: }
  end

private

  def additional_guidance_form_params
    params.require(:pages_additional_guidance_form).permit(:page_heading, :additional_guidance_markdown)
  end
end
