module Forms
  class ReceiveCsvController < ApplicationController
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
      @receive_csv_input = ReceiveCsvInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @receive_csv_input = ReceiveCsvInput.new(receive_csv_input_params)
      previous_submission_type = @receive_csv_input.form.submission_type
      new_submission_type = @receive_csv_input.submission_type

      if @receive_csv_input.submit
        redirect_to form_path(@receive_csv_input.form), success: success_message(previous_submission_type, new_submission_type)
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def receive_csv_input_params
      params.require(:forms_receive_csv_input).permit(:submission_type).merge(form: current_form)
    end

    def success_message(previous_submission_type, new_submission_type)
      return nil if previous_submission_type == new_submission_type

      return t("banner.success.form.receive_csv_enabled") if new_submission_type == "email_with_csv"

      t("banner.success.form.receive_csv_disabled") if new_submission_type == "email"
    end
  end
end
