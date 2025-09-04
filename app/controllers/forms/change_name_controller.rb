module Forms
  class ChangeNameController < WebController
    after_action :verify_authorized

    def edit
      authorize current_form, :can_view_form?
      @name_input = NameInput.new(form: current_form).assign_form_values
    end

    def update
      authorize current_form, :can_view_form?
      @name_input = NameInput.new(name_input_params(current_form))

      if @name_input.submit
        redirect_to form_path(@name_input.form.id), success: t("banner.success.form.change_name")
      else
        render :edit
      end
    end

  private

    def name_input_params(form)
      params.require(:forms_name_input).permit(:name).merge(form:)
    end
  end
end
