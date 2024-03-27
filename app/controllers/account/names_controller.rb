module Account
  class NamesController < ApplicationController
    skip_before_action :check_user_account_complete
    before_action :redirect_if_name_exists

    def edit
      @name_form = NameForm.new(user: current_user).assign_form_values
    end

    def update
      @name_form = NameForm.new(account_name_form_params(current_user))

      if @name_form.submit
        redirect_to root_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def account_name_form_params(user)
      params.require(:account_name_form).permit(:name).merge(user:)
    end

  private

    def redirect_if_name_exists
      redirect_to root_path if current_user.name.present?
    end
  end
end
