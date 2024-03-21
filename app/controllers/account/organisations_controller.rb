module Account
  class OrganisationsController < ApplicationController
    before_action :redirect_if_organisation_exists

    def edit
      @organisation_form = OrganisationForm.new(user: current_user).assign_form_values
    end

    def update
      @organisation_form = OrganisationForm.new(account_organisation_form_params(current_user))

      if @organisation_form.submit
        redirect_to root_path
      else
        render :edit
      end
    end

    def account_organisation_form_params(user)
      params.require(:account_organisation_form).permit(:organisation_id).merge(user:)
    end

  private

    def redirect_if_organisation_exists
      redirect_to root_path if current_user.organisation.present?
    end
  end
end
