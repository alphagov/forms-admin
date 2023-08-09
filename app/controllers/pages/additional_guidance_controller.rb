require "govuk_forms_markdown"

class Pages::AdditionalGuidanceController < PagesController
  def new
    page_heading = session.dig(:page, "page_heading")
    additional_guidance_markdown = session.dig(:page, "additional_guidance_markdown")
    additional_guidance_form = Pages::AdditionalGuidanceForm.new(page_heading:, additional_guidance_markdown:)
    render "pages/additional_guidance", locals: { form: @form, page: @page, additional_guidance_form:, preview_html: nil }
  end

  def create
    additional_guidance_form = Pages::AdditionalGuidanceForm.new(additional_guidance_form_params)

    case route_to
    when :preview
      preview_html = GovukFormsMarkdown.render(additional_guidance_form.additional_guidance_markdown)
      render "pages/additional_guidance", locals: { form: @form, page: @page, additional_guidance_form:, preview_html: }
    when :save_and_continue
      if additional_guidance_form.submit(session)
        redirect_to new_page_path(@form)
      else
        render "pages/additional_guidance", locals: { form: @form, page: @page, additional_guidance_form:, preview_html: }, status: :unprocessable_entity
      end
    end
  end

private

  def additional_guidance_form_params
    params.require(:pages_additional_guidance_form).permit(:page_heading, :additional_guidance_markdown)
  end

  def route_to
    params[:route_to].to_sym
  end
end
