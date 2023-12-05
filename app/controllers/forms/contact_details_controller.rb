module Forms
  class ContactDetailsController < ApplicationController
    after_action :verify_authorized
    def new
      authorize current_form, :can_view_form?
      @contact_details_form = ContactDetailsForm.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @contact_details_form = ContactDetailsForm.new(**contact_details_form_params)

      if @contact_details_form.submit
        redirect_to form_path(@contact_details_form.form), success: t("banner.success.form.support_details_saved")
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def contact_details_form_params
      params.require(:forms_contact_details_form).permit(:email, :phone, :link_href, :link_text, contact_details_supplied: []).merge(form: current_form, current_user:)
    end
  end
end
