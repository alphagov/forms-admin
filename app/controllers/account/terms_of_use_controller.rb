module Account
  class TermsOfUseController < ApplicationController
    include AfterSignInPathHelper

    before_action :redirect_if_terms_agreed
    skip_before_action :redirect_if_account_not_completed

    def edit
      @terms_of_use_input = TermsOfUseInput.new(user: current_user)
    end

    def update
      @terms_of_use_input = TermsOfUseInput.new(account_terms_of_use_input_params(current_user))

      if @terms_of_use_input.submit
        redirect_to next_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def account_terms_of_use_input_params(user)
      params.require(:account_terms_of_use_input).permit(:agreed).merge(user:)
    end

  private

    def redirect_if_terms_agreed
      redirect_to root_path if current_user.terms_agreed_at.present?
    end

    def next_path
      after_sign_in_next_path
    end
  end
end
