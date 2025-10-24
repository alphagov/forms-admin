module Forms
  class WelshTranslationController < WebController
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
      @welsh_translation_input = WelshTranslationInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @welsh_translation_input = WelshTranslationInput.new(**welsh_translation_input_params)

      if @welsh_translation_input.submit
        redirect_to form_path(@welsh_translation_input.form)
      else
        render :new
      end
    end

    def welsh_translation_input_params
      params.require(:forms_welsh_translation_input).permit(:mark_complete).merge(form: current_form)
    end
  end
end
