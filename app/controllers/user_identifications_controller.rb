class UserIdentificationsController < ApplicationController

  def edit
    @user_identification_form = UserIdentificationForm.new(user: current_user).assign_form_values
  end

  def update
    @user_identification_form = UserIdentificationForm.new(user_identification_form_params(current_user))

    if @user_identification_form.submit
      redirect_to root_path
    else
      render :edit
    end
  end

  def user_identification_form_params(user)
    params.require(:user_identification_form).permit(:name, :organisation_id).merge(user:)
  end
end
