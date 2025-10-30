module Forms
  class WelshTranslationController < WebController
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
      return redirect_to form_path(current_form) unless welsh_enabled?

      @welsh_translation_input = WelshTranslationInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      return redirect_to form_path(current_form) unless welsh_enabled?

      @welsh_translation_input = WelshTranslationInput.new(**welsh_translation_input_params)

      if @welsh_translation_input.submit
        success_message = if @welsh_translation_input.mark_complete == "true"
                            t("banner.success.form.welsh_translation_saved_and_completed")
                          else
                            t("banner.success.form.welsh_translation_saved")
                          end

        redirect_to form_path(@welsh_translation_input.form), success: success_message
      else
        render :new, status: :unprocessable_content
      end
    end

    def welsh_translation_input_params
      params.require(:forms_welsh_translation_input).permit(:mark_complete, pages: %i[id question_text_cy hint_text_cy page_heading_cy guidance_markdown_cy]).merge(form: current_form)
    end

    def welsh_enabled?
      FeatureService.new(group: current_form.group).enabled?(:welsh)
    end
  end
end
