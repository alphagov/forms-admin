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

      if @receive_csv_input.submit
        redirect_to form_path(@receive_csv_input.form)
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def receive_csv_input_params
      params.require(:forms_receive_csv_input).permit(:submission_type).merge(form: current_form)
    end
  end
end
