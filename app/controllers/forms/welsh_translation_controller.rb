module Forms
  class WelshTranslationController < WebController
    after_action :verify_authorized

    def new
      authorize current_form, :can_edit_form?
      return redirect_to form_path(current_form) unless welsh_enabled?

      @welsh_translation_input = WelshTranslationInput.new(form: current_form, page_translations: welsh_page_translation_inputs_from_page).assign_form_values
    end

    def create
      authorize current_form, :can_edit_form?
      return redirect_to form_path(current_form) unless welsh_enabled?

      @welsh_translation_input = WelshTranslationInput.new(**welsh_translation_input_params, page_translations: welsh_page_translation_inputs_from_params)

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

  private

    def welsh_enabled?
      FeatureService.new(group: current_form.group).enabled?(:welsh)
    end

    def welsh_translation_input_params
      params.require(:forms_welsh_translation_input).permit(WelshTranslationInput.attribute_names).merge(form: current_form)
    end

    def page_translation_input_params
      params.require(:forms_welsh_translation_input).permit(:mark_complete, page_translations: WelshPageTranslationInput.attribute_names)
    end

    def condition_translation_input_params
      params.require(:forms_welsh_translation_input).permit(:mark_complete, condition_translations: WelshConditionTranslationInput.attribute_names)
    end

    def welsh_page_translation_inputs_from_page
      current_form.pages.map do |page|
        condition_translations = page.routing_conditions.map { |condition| WelshConditionTranslationInput.new(id: condition.id).assign_condition_values }

        WelshPageTranslationInput.new(id: page.id, condition_translations:).assign_page_values
      end
    end

    def welsh_page_translation_inputs_from_params
      return [] if page_translation_input_params[:page_translations].blank?

      page_translation_input_params[:page_translations].each_value.map do |page_translation|
        condition_translations = welsh_condition_translation_inputs_from_params.filter { |condition_translation| condition_translation.condition.routing_page_id == page_translation["id"].to_i }

        WelshPageTranslationInput.new(**page_translation, mark_complete: page_translation_input_params[:mark_complete], condition_translations:)
      end
    end

    def welsh_condition_translation_inputs_from_condition
      current_form.conditions.map { |condition| WelshConditionTranslationInput.new(id: condition.id).assign_condition_values }
    end

    def welsh_condition_translation_inputs_from_params
      return [] if condition_translation_input_params[:condition_translations].blank?

      condition_translation_input_params[:condition_translations].each_value.map { |condition_translation| WelshConditionTranslationInput.new(**condition_translation, mark_complete: condition_translation_input_params[:mark_complete]) }
    end
  end
end
