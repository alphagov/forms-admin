module Account
  class ContactForResearchController < ApplicationController
    include AfterSignInPathHelper

    # before_action :redirect_contact_for_research_set
    skip_before_action :redirect_if_account_not_completed

    def edit
      @contact_for_research_input = ContactForResearchInput.new(research_contact_status:, user: current_user)
    end

    def update
      @contact_for_research_input = ContactForResearchInput.new(account_contact_for_research_params(current_user))

      if @contact_for_research_input.submit
        redirect_to next_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def account_contact_for_research_params(user)
      params.require(:account_contact_for_research_input).permit(:research_contact_status).merge(user:)
    end

  private

    def redirect_contact_for_research_set
      redirect_to root_path unless current_user.research_contact_to_be_asked?
    end

    def research_contact_status
      current_user.research_contact_status.to_sym if current_user.research_contact_status.in?(ContactForResearchInput::RADIO_OPTIONS)
    end

    def next_path
      after_sign_in_next_path
    end
  end
end
