module Forms
  class SubmissionAttachmentsController < WebController
    before_action :json_submission_enabled?
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
      @submission_attachments_input = SubmissionAttachmentsInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @submission_attachments_input = SubmissionAttachmentsInput.new(submission_attachments_input_params)

      if @submission_attachments_input.submit
        redirect_to form_path(current_form.id), success: success_message(current_form)
      else
        render :new, status: :unprocessable_content
      end
    end

  private

    def submission_attachments_input_params
      params.require(:forms_submission_attachments_input).permit(submission_format: []).merge(form: current_form)
    end

    def json_submission_enabled?
      redirect_to error_404_path unless Settings.features.json_submission_enabled
    end

    def success_message(form)
      return nil unless form.submission_format_previously_changed?

      case form.submission_format
      when []
        t("banner.success.form.receive_no_attachments")
      when %w[csv]
        t("banner.success.form.receive_csv_enabled")
      when %w[json]
        t("banner.success.form.receive_json_enabled")
      when %w[csv json]
        t("banner.success.form.receive_csv_and_json_enabled")
      end
    end
  end
end
