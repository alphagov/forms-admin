module Forms
  class ConfirmEmailController < BaseController
    def new
      @confirm_email_form = ConfirmEmailForm.new(form: current_form)
    end

    def create
      @confirm_email_form = ConfirmEmailForm.new(confirm_email_form_params)

      if @confirm_email_form.submit
        redirect_to confirm_form_email_sucess_path(@confirm_email_form.form)
      else
        render :new
      end
    end

    def success
      @form = current_form
    end

    def confirm_email_form_params
      params.require(:forms_confirm_email_form).permit(:email_code).merge(form: current_form)
    end
  end
end
