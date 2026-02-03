module Forms
  class WelshTranslationController < WebController
    after_action :verify_authorized

    def new
      authorize current_form, :can_edit_form?
      return redirect_to form_path(current_form) unless welsh_enabled?

      @welsh_translation_input = WelshTranslationInput.new(form: form_with_pages_and_conditions).assign_form_values
      @table_presenter = Forms::TranslationTablePresenter.new
    end

    def create
      authorize current_form, :can_edit_form?
      return redirect_to form_path(current_form) unless welsh_enabled?

      @welsh_translation_input = WelshTranslationInput.new(welsh_translation_params)
      @table_presenter = Forms::TranslationTablePresenter.new

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

    def delete
      authorize current_form, :can_edit_form?
      return redirect_to form_path(current_form) unless welsh_enabled?

      @delete_welsh_translation_input = Forms::DeleteWelshTranslationInput.new(form: current_form)
    end

    def destroy
      authorize current_form, :can_edit_form?
      return redirect_to form_path(current_form) unless welsh_enabled?

      @delete_welsh_translation_input = Forms::DeleteWelshTranslationInput.new(delete_welsh_translation_params)

      if @delete_welsh_translation_input.submit
        if @delete_welsh_translation_input.confirmed?
          redirect_to form_path(@delete_welsh_translation_input.form), success: t(".success")
        else
          redirect_to welsh_translation_path(@delete_welsh_translation_input.form)
        end
      else
        render :delete, status: :unprocessable_content
      end
    end

  private

    def welsh_enabled?
      FeatureService.new(group: current_form.group).enabled?(:welsh)
    end

    def welsh_translation_params
      params.require(:forms_welsh_translation_input).permit(
        *WelshTranslationInput.attribute_names,
        page_translations_attributes: [
          *WelshPageTranslationInput.attribute_names,
          { selection_options_cy_attributes: %i[id name_cy] },
          { condition_translations_attributes: WelshConditionTranslationInput.attribute_names },
        ],
      ).merge(form: current_form)
    end

    def delete_welsh_translation_params
      params.require(:forms_delete_welsh_translation_input).permit(:confirm).merge(form: current_form)
    end

    def form_with_pages_and_conditions
      Form.includes(pages: [:routing_conditions]).find(current_form.id)
    end
  end
end
