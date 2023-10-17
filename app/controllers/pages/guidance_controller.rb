require "govuk_forms_markdown"

class Pages::GuidanceController < PagesController
  def new
    page_heading = session.dig(:page, :page_heading)
    guidance_markdown = session.dig(:page, :guidance_markdown)
    guidance_form = Pages::GuidanceForm.new(page_heading:, guidance_markdown:)
    back_link = new_question_path(@form)
    render "pages/guidance", locals: view_locals(nil, guidance_form, back_link)
  end

  def create
    guidance_form = Pages::GuidanceForm.new(guidance_form_params)
    back_link = new_question_path(@form)

    case route_to
    when :preview
      guidance_form.valid?
      render "pages/guidance", locals: view_locals(nil, guidance_form, back_link)
    when :save_and_continue
      if guidance_form.submit(session)
        redirect_to new_question_path(@form)
      else
        render "pages/guidance", locals: view_locals(nil, guidance_form, back_link), status: :unprocessable_entity
      end
    end
  end

  def edit
    page.load_from_session(session, %i[answer_type page_heading guidance_markdown])

    guidance_form = Pages::GuidanceForm.new(page_heading: page.page_heading,
                                            guidance_markdown: page.guidance_markdown)
    back_link = edit_question_path(@form, page)

    render "pages/guidance", locals: view_locals(page, guidance_form, back_link)
  end

  def update
    guidance_form = Pages::GuidanceForm.new(guidance_form_params)
    back_link = edit_question_path(@form, page.id)

    case route_to
    when :preview
      guidance_form.valid?
      render "pages/guidance", locals: view_locals(page, guidance_form, back_link)
    when :save_and_continue
      if guidance_form.submit(session)
        redirect_to edit_question_path(@form.id, page.id)
      else
        render "pages/guidance", locals: view_locals(page, guidance_form, back_link), status: :unprocessable_entity
      end
    end
  end

  def render_preview
    guidance_form = Pages::GuidanceForm.new(guidance_markdown: params[:guidance_markdown])
    guidance_form.validate

    render json: { preview_html: preview_html(guidance_form), errors: guidance_form.errors[:guidance_markdown] }.to_json
  end

private

  def guidance_form_params
    params.require(:pages_guidance_form).permit(:page_heading, :guidance_markdown).merge(draft_question:)
  end

  def route_to
    params[:route_to].to_sym
  end

  def preview_html(guidance_form)
    return t("guidance.no_guidance_added_html") if guidance_form.guidance_markdown.blank?

    GovukFormsMarkdown.render(guidance_form.guidance_markdown)
  end

  def view_locals(current_page, guidance_form, back_link)
    post_url = current_page.present? && current_page.id.present? ? guidance_edit_path : guidance_new_path
    { form: @form, page: @page, guidance_form:, preview_html: preview_html(guidance_form), post_url:, back_link: }
  end
end
