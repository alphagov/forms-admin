module Account
  class NamesController < ApplicationController
    include AfterSignInPathHelper

    before_action :redirect_if_name_exists
    skip_before_action :redirect_if_account_not_completed

    def edit
      @name_input = NameInput.new(user: current_user).assign_form_values
    end

    def update
      @name_input = NameInput.new(account_name_input_params(current_user))

      if @name_input.submit
        redirect_to next_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def account_name_input_params(user)
      params.require(:account_name_input).permit(:name).merge(user:)
    end

  private

    def redirect_if_name_exists
      redirect_to root_path if current_user.name.present?
    end

    def next_path
      after_sign_in_next_path
    end
  end
end
