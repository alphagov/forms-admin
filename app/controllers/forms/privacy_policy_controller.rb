module Forms
  class PrivacyPolicyController < ApplicationController
    after_action :verify_authorized
    def new
      authorize current_form, :can_view_form?
      @privacy_policy_input = PrivacyPolicyInput.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @privacy_policy_input = PrivacyPolicyInput.new(privacy_policy_input_params)

      if @privacy_policy_input.submit
        redirect_to form_path(@privacy_policy_input.form), success: t("banner.success.form.privacy_details_saved")
      else
        render :new
      end
    end

  private

    def privacy_policy_input_params
      params.require(:forms_privacy_policy_input).permit(:privacy_policy_url).merge(form: current_form)
    end
  end
end
