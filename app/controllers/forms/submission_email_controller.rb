module Forms
  class SubmissionEmailController < ApplicationController
    before_action :submission_email_input, except: %i[create confirm_submission_email_code]
    after_action :verify_authorized

    def new
      authorize current_form, :can_change_form_submission_email?
    end

    def create
      authorize current_form, :can_change_form_submission_email?
      @submission_email_input = SubmissionEmailInput.new(set_submission_email_input_params)

      if @submission_email_input.submit
        redirect_to submission_email_code_sent_path(@submission_email_input.form)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def submission_email_code_sent
      authorize current_form, :can_change_form_submission_email?
    end

    def submission_email_code
      authorize current_form, :can_change_form_submission_email?
    end

    def confirm_submission_email_code
      authorize current_form, :can_change_form_submission_email?
      @submission_email_input = SubmissionEmailInput.new(set_email_code_form_params).assign_form_values

      if @submission_email_input.confirm_confirmation_code
        redirect_to submission_email_confirmed_path(@submission_email_input.form)
      else
        render :submission_email_code, status: :unprocessable_entity
      end
    end

    def submission_email_confirmed
      authorize current_form, :can_change_form_submission_email?

      render :submission_email_confirmed, locals: { live_submission_email_updated: live_submission_email_updated? }
    end

  private

    def set_submission_email_input_params
      params.require(:forms_submission_email_input).permit(:temporary_submission_email, :notify_response_id).merge(form: current_form).merge(current_user:)
    end

    def set_email_code_form_params
      params.require(:forms_submission_email_input).permit(:email_code).merge(form: current_form).merge(current_user:)
    end

    def submission_email_input
      @submission_email_input ||= SubmissionEmailInput.new(form: current_form).assign_form_values
    end

    def live_submission_email_updated?
      return false unless FeatureService.enabled?(:notify_original_submission_email_of_change) && current_form.is_live?

      current_live_form.submission_email != current_form.submission_email
    end

    def current_live_form
      @current_live_form ||= Form.find_live(params[:form_id])
    end
  end
end
