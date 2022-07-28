module Forms
  class ChangeEmailController < BaseController
    def new
      @change_email_form = ChangeEmailForm.new(form: current_form).assign_form_values
    end

    def create
      @change_email_form = ChangeEmailForm.new(change_email_form_params)

      if @change_email_form.submit
        redirect_to form_path(@change_email_form.form)
      else
        render :new
      end
    end

  private

    def change_email_form_params
      params.require(:forms_change_email_form).permit(:submission_email).merge(form: current_form)
    end
  end
end
