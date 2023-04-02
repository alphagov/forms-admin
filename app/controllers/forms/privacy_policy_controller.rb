module Forms
  class PrivacyPolicyController < BaseController
    after_action :verify_authorized
    def new
      authorize current_form, :edit?
      @privacy_policy_form = PrivacyPolicyForm.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :edit?
      @privacy_policy_form = PrivacyPolicyForm.new(privacy_policy_form_params)

      if @privacy_policy_form.submit
        redirect_to form_path(@privacy_policy_form.form)
      else
        render :new
      end
    end

  private

    def privacy_policy_form_params
      params.require(:forms_privacy_policy_form).permit(:privacy_policy_url).merge(form: current_form)
    end
  end
end
