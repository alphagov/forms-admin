module Forms
  class DailySubmissionBatchController < WebController
    before_action :check_feature_flag
    after_action :verify_authorized

    def new
      authorize current_form, :can_edit_form?
      @daily_submission_batch_input = Forms::DailySubmissionBatchInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_edit_form?
      @daily_submission_batch_input = Forms::DailySubmissionBatchInput.new(daily_submission_batch_input_params)

      if @daily_submission_batch_input.submit
        redirect_to form_path(current_form.id), success: success_message(current_form)
      else
        render :new, status: :unprocessable_content
      end
    end

  private

    def check_feature_flag
      raise NotFoundError unless FeatureService.enabled?(:daily_submission_emails_enabled)
    end

    def daily_submission_batch_input_params
      params.require(:forms_daily_submission_batch_input).permit(:send_daily_submission_batch).merge(form: current_form)
    end

    def success_message(form)
      return nil unless form.send_daily_submission_batch_previously_changed?

      if form.send_daily_submission_batch
        t("banner.success.form.daily_submission_batch_enabled")
      else
        t("banner.success.form.daily_submission_batch_disabled")
      end
    end
  end
end
