module Forms
  class PaymentLinkController < WebController
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
      @payment_link_input = PaymentLinkInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @payment_link_input = PaymentLinkInput.new(payment_link_input_params)
      previous_payment_url = current_form.payment_url

      if @payment_link_input.submit
        success_message = success_message(previous_payment_url, @payment_link_input.payment_url)
        redirect_to form_path(@payment_link_input.form.id), success: success_message
      else
        render :new, status: :unprocessable_content
      end
    end

  private

    def payment_link_input_params
      params.require(:forms_payment_link_input).permit(:payment_url).merge(form: current_form)
    end

    def success_message(previous_payment_url, new_payment_url)
      return t("banner.success.form.payment_link_saved") if new_payment_url.present? && new_payment_url != previous_payment_url
      return t("banner.success.form.payment_link_removed") if new_payment_url.blank? && previous_payment_url.present?

      nil
    end
  end
end
