module Forms
  class ChangeNameController < BaseController
    def new
      @change_name_form = ChangeNameForm.new(form: current_form).assign_form_values
    end

    def create
      @change_name_form = ChangeNameForm.new(change_name_form_params)

      if @change_name_form.submit
        redirect_to form_path(@change_name_form.form)
      else
        render :new
      end
    end

  private

    def change_name_form_params
      params.require(:forms_change_name_form).permit(:name).merge(form: current_form)
    end
  end
end
