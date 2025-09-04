module Forms
  class WhatHappensNextController < WebController
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
      @what_happens_next_input = WhatHappensNextInput.new(form: current_form).assign_form_values
      @preview_html = preview_html(@what_happens_next_input)
    end

    def create
      authorize current_form, :can_view_form?
      @what_happens_next_input = WhatHappensNextInput.new(**what_happens_next_input_params)
      @preview_html = preview_html(@what_happens_next_input)

      case params[:route_to].to_sym
      when :preview
        if @what_happens_next_input.valid?
          render :new, status: :ok
        else
          render :new, status: :unprocessable_content
        end
      when :save_and_continue
        if @what_happens_next_input.submit
          redirect_to form_path(@what_happens_next_input.form.id), success: t("banner.success.form.what_happens_next_saved")
        else
          render :new, status: :unprocessable_content
        end
      end
    end

    def render_preview
      authorize current_form, :can_view_form?
      @what_happens_next_input = WhatHappensNextInput.new(what_happens_next_markdown: params[:markdown])
      @what_happens_next_input.validate

      render json: { preview_html: preview_html(@what_happens_next_input), errors: @what_happens_next_input.errors[:what_happens_next_markdown] }.to_json
    end

  private

    def what_happens_next_input_params
      params.require(:forms_what_happens_next_input).permit(:what_happens_next_markdown).merge(form: current_form)
    end

    def preview_html(what_happens_next_input)
      return t("guidance.no_guidance_added_html") if what_happens_next_input.what_happens_next_markdown.blank?

      GovukFormsMarkdown.render(what_happens_next_input.what_happens_next_markdown, allow_headings: false)
    end
  end
end
