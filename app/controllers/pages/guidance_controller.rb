require "govuk_forms_markdown"

class Pages::GuidanceController < PagesController
  def new
    page_heading = session.dig(:page, "page_heading")
    guidance_markdown = session.dig(:page, "guidance_markdown")
    additional_guidance_form = Pages::GuidanceForm.new(page_heading:, guidance_markdown:)
    render "pages/guidance", locals: view_locals(nil, additional_guidance_form)
  end

  def create
    additional_guidance_form = Pages::GuidanceForm.new(additional_guidance_form_params)

    case route_to
    when :preview
      render "pages/guidance", locals: view_locals(nil, additional_guidance_form)
    when :save_and_continue
      if additional_guidance_form.submit(session)
        redirect_to new_page_path(@form)
      else
        render "pages/guidance", locals: view_locals(nil, additional_guidance_form), status: :unprocessable_entity
      end
    end
  end

  def edit
    page.load_from_session(session, %w[answer_type page_heading guidance_markdown])

    additional_guidance_form = Pages::GuidanceForm.new(page_heading: page.page_heading,
                                                       guidance_markdown: page.guidance_markdown)

    render "pages/guidance", locals: view_locals(page, additional_guidance_form)
  end

  def update
    additional_guidance_form = Pages::GuidanceForm.new(additional_guidance_form_params)

    case route_to
    when :preview
      render "pages/guidance", locals: view_locals(page, additional_guidance_form)
    when :save_and_continue
      if additional_guidance_form.submit(session)
        redirect_to edit_page_path(@form.id, page.id)
      else
        render "pages/guidance", locals: view_locals(page, additional_guidance_form), status: :unprocessable_entity
      end
    end
  end

  def render_preview
    additional_guidance_form = Pages::GuidanceForm.new(guidance_markdown: params[:guidance_markdown])

    render json: { preview_html: preview_html(additional_guidance_form) }.to_json
  end

private

  def additional_guidance_form_params
    params.require(:pages_additional_guidance_form).permit(:page_heading, :guidance_markdown)
  end

  def route_to
    params[:route_to].to_sym
  end

  def preview_html(guidance_form)
    return "<p>You have no content to preview</p>" if guidance_form.guidance_markdown.blank?

    GovukFormsMarkdown.render(guidance_form.guidance_markdown)
  end

  def view_locals(current_page, guidance_form)
    post_url = current_page.present? && current_page.id.present? ? additional_guidance_edit_path : additional_guidance_new_path
    { form: @form, page: @page, additional_guidance_form: guidance_form, preview_html: preview_html(guidance_form), post_url: }
  end
end
