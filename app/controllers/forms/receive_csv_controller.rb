module Forms
  class ReceiveCsvController < WebController
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
      @submission_type_input = SubmissionTypeInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @submission_type_input = SubmissionTypeInput.new(submission_type_input_params)

      if @submission_type_input.submit
        redirect_to form_path(@submission_type_input.form.id), success: success_message(@submission_type_input.form)
      else
        render :new, status: :unprocessable_content
      end
    end

  private

    def submission_type_input_params
      params.require(:forms_submission_type_input).permit(:submission_type).merge(form: current_form)
    end

    def success_message(form)
      return nil unless form.submission_type_previously_changed?

      return t("banner.success.form.receive_csv_enabled") if form.submission_type.include? "csv"

      t("banner.success.form.receive_csv_disabled")
    end
  end
end
