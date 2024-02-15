module Forms
  class PaymentLinkController < ApplicationController
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
      @payment_link_form = PaymentLinkForm.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @payment_link_form = PaymentLinkForm.new(payment_link_form_params)

      if @payment_link_form.submit
        redirect_to form_path(@payment_link_form.form), success: t("banner.success.form.payment_link_saved")
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def payment_link_form_params
      params.require(:forms_payment_link_form).permit(:payment_url).merge(form: current_form)
    end
  end
end
