module Forms
  class SubmissionEmailController < BaseController
    before_action :submission_email_form, except: %i[create confirm_submission_email_code]

    def new; end

    def create
      @submission_email_form = SubmissionEmailForm.new(set_email_form_params)

      if @submission_email_form.submit
        redirect_to submission_email_code_sent_path(@submission_email_form.form)
      else
        render :new
      end
    end

    def submission_email_code_sent; end

    def submission_email_code; end

    def confirm_submission_email_code
      @submission_email_form = SubmissionEmailForm.new(set_email_code_form_params).assign_form_values

      if @submission_email_form.confirm_confirmation_code
        redirect_to submission_email_confirmed_path(@submission_email_form.form)
      else
        render :submission_email_code
      end
    end

    def submission_email_confirmed; end

  private

    def set_email_form_params
      params.require(:forms_submission_email_form).permit(:temporary_submission_email, :notify_response_id).merge(form: current_form).merge(user_information:)
    end

    def set_email_code_form_params
      params.require(:forms_submission_email_form).permit(:email_code).merge(form: current_form).merge(user_information:)
    end

    def submission_email_form
      @submission_email_form ||= SubmissionEmailForm.new(form: current_form).assign_form_values
    end
  end
end
