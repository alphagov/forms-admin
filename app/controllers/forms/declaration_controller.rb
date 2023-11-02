module Forms
  class DeclarationController < ApplicationController
    after_action :verify_authorized
    def new
      authorize current_form, :can_view_form?
      @declaration_form = DeclarationForm.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @declaration_form = DeclarationForm.new(**declaration_form_params)

      if @declaration_form.submit
        success_message = if @declaration_form.mark_complete == "true"
                            t("banner.success.form.declaration_saved_and_completed")
                          else
                            t("banner.success.form.declaration_saved")
                          end

        redirect_to form_path(@declaration_form.form), success: success_message
      else
        render :new
      end
    end

  private

    def declaration_form_params
      params.require(:forms_declaration_form).permit(:declaration_text, :mark_complete).merge(form: current_form)
    end
  end
end
