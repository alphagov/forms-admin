module Forms
  class SetEmailController < BaseController
    def new
      @set_email_form = SetEmailForm.new(form: current_form).assign_form_values
    end

    def create
      @set_email_form = SetEmailForm.new(set_email_form_params)

      if @set_email_form.submit
        redirect_to form_path(@set_email_form.form)
      else
        render :new
      end
    end

    def set_email_form_params
      params.require(:forms_set_email_form).permit(:submission_email).merge(form: current_form)
    end
  end
end
