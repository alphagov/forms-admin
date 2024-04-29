module Forms
  class DeclarationController < ApplicationController
    after_action :verify_authorized
    def new
      authorize current_form, :can_view_form?
      @declaration_input = DeclarationInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @declaration_input = DeclarationInput.new(**declaration_input_params)

      if @declaration_input.submit
        success_message = if @declaration_input.mark_complete == "true"
                            t("banner.success.form.declaration_saved_and_completed")
                          else
                            t("banner.success.form.declaration_saved")
                          end

        redirect_to form_path(@declaration_input.form), success: success_message
      else
        render :new
      end
    end

  private

    def declaration_input_params
      params.require(:forms_declaration_input).permit(:declaration_text, :mark_complete).merge(form: current_form)
    end
  end
end
