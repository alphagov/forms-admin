module Forms
  class SubmissionEmailController < BaseController
    def new
      @submission_email_form = SubmissionEmailForm.new(form: current_form).assign_form_values
    end

    def create
      @submission_email_form = SubmissionEmailForm.new(set_email_form_params)

      if @submission_email_form.submit
        redirect_to submission_email_code_sent_path(@submission_email_form.form)
      else
        render :new
      end
    end

    def submission_email_code_sent
      @submission_email_form = SubmissionEmailForm.new(form: current_form).assign_form_values
    end

    def submission_email_code
      @submission_email_form = SubmissionEmailForm.new(form: current_form).assign_form_values
    end

    def confirm_submission_email_code
      @submission_email_form = SubmissionEmailForm.new(set_email_code_form_params).assign_form_values

      if @submission_email_form.confirm_confirmation_code
        redirect_to submission_email_confirmed_path(@submission_email_form.form)
      else
        render :submission_email_code
      end
    end

    def submission_email_confirmed
      @submission_email_form = SubmissionEmailForm.new(form: current_form).assign_form_values
    end

  private

    def set_email_form_params
      params.require(:forms_submission_email_form).permit(:temporary_submission_email).merge(form: current_form).merge(current_user:)
    end

    def set_email_code_form_params
      params.require(:forms_submission_email_form).permit(:email_code).merge(form: current_form).merge(current_user:)
    end
  end
end
