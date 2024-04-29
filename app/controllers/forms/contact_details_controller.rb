module Forms
  class ContactDetailsController < ApplicationController
    after_action :verify_authorized
    def new
      authorize current_form, :can_view_form?
      @contact_details_input = ContactDetailsInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @contact_details_input = ContactDetailsInput.new(**contact_details_input_params)

      if @contact_details_input.submit
        redirect_to form_path(@contact_details_input.form), success: t("banner.success.form.support_details_saved")
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def contact_details_input_params
      params.require(:forms_contact_details_input).permit(:email, :phone, :link_href, :link_text, contact_details_supplied: []).merge(form: current_form, current_user:)
    end
  end
end
