module Forms
  class ChangeNameController < BaseController
    def new
      @change_name_form = ChangeNameForm.new
    end

    def create
      form = Form.new({
        name: params[:name],
        org: @current_user.organisation_slug,
      })
      @change_name_form = ChangeNameForm.new(change_name_form_params(form))

      if @change_name_form.submit
        redirect_to form_path(@change_name_form.form)
      else
        render :new
      end
    end

    def edit
      @change_name_form = ChangeNameForm.new(form: current_form).assign_form_values
    end

    def update
      @change_name_form = ChangeNameForm.new(change_name_form_params(current_form))

      if @change_name_form.submit
        redirect_to form_path(@change_name_form.form)
      else
        render :edit
      end
    end

  private

    def change_name_form_params(form)
      params.require(:forms_change_name_form).permit(:name).merge(form:)
    end
  end
end
