module Forms
  class PaymentLinkController < ApplicationController
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
      @payment_link_input = PaymentLinkInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @payment_link_input = PaymentLinkInput.new(payment_link_input_params)

      if @payment_link_input.submit
        redirect_to form_path(@payment_link_input.form), success: t("banner.success.form.payment_link_saved")
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def payment_link_input_params
      params.require(:forms_payment_link_input).permit(:payment_url).merge(form: current_form)
    end
  end
end
