module Forms
  class DeclarationController < BaseController
    after_action :verify_authorized
    def new
      authorize current_form, :update?
      @declaration_form = DeclarationForm.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :update?
      @declaration_form = DeclarationForm.new(**declaration_form_params)

      if @declaration_form.submit
        redirect_to form_path(@declaration_form.form)
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
