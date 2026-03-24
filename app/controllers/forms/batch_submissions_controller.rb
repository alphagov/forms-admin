module Forms
  class BatchSubmissionsController < FormsController
    def new
      authorize current_form, :can_edit_form?
      @batch_submissions_input = Forms::BatchSubmissionsInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_edit_form?
      @batch_submissions_input = Forms::BatchSubmissionsInput.new(batch_submissions_input_params)

      if @batch_submissions_input.submit
        redirect_to form_path(current_form.id), success: success_message(current_form)
      else
        render :new, status: :unprocessable_content
      end
    end

  private

    def batch_submissions_input_params
      params.require(:forms_batch_submissions_input).permit(batch_frequencies: []).merge(form: current_form)
    end

    def success_message(form)
      return nil unless form.send_daily_submission_batch_previously_changed? || form.send_weekly_submission_batch_previously_changed?

      unless FeatureService.enabled?(:weekly_submission_emails_enabled)
        return form.send_daily_submission_batch ? t("banner.success.form.daily_submission_batch_enabled") : t("banner.success.form.daily_submission_batch_disabled")
      end

      if form.send_daily_submission_batch && form.send_weekly_submission_batch
        t("banner.success.form.batch_submissions.daily_and_weekly_enabled")
      elsif form.send_daily_submission_batch
        t("banner.success.form.batch_submissions.daily_enabled")
      elsif form.send_weekly_submission_batch
        t("banner.success.form.batch_submissions.weekly_enabled")
      else
        t("banner.success.form.batch_submissions.disabled")
      end
    end
  end
end
