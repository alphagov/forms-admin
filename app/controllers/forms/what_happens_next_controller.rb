module Forms
  class WhatHappensNextController < ApplicationController
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
      @what_happens_next_form = WhatHappensNextForm.new(form: current_form).assign_form_values
      @preview_html = preview_html(@what_happens_next_form)
    end

    def create
      authorize current_form, :can_view_form?
      @what_happens_next_form = WhatHappensNextForm.new(**what_happens_next_form_params)
      @preview_html = preview_html(@what_happens_next_form)

      if @what_happens_next_form.submit
        redirect_to form_path(@what_happens_next_form.form), success: t("banner.success.form.what_happens_next_saved")
      else
        render :new
      end
    end

    def render_preview
      authorize current_form, :can_view_form?
      @what_happens_next_form = WhatHappensNextForm.new(what_happens_next_markdown: params[:markdown])
      @what_happens_next_form.validate

      render json: { preview_html: preview_html(@what_happens_next_form), errors: @what_happens_next_form.errors[:what_happens_next_markdown] }.to_json
    end

  private

    def what_happens_next_form_params
      params.require(:forms_what_happens_next_form).permit(:what_happens_next_text, :what_happens_next_markdown).merge(form: current_form)
    end

    def preview_html(what_happens_next_form)
      return t("guidance.no_guidance_added_html") if what_happens_next_form.what_happens_next_markdown.blank?

      GovukFormsMarkdown.render(what_happens_next_form.what_happens_next_text)
    end
  end
end
