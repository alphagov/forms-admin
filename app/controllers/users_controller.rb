class UsersController < ApplicationController
  before_action :can_manage_user

  def index
    render template: "users/index", locals: { users: User.all }
  end

  def edit
    user
  end

  def update
    user.update!(user_params)
    redirect_to users_path
  end

private
  def user
    @user ||= User.find(params[:id])
  end

  def can_manage_user
    authorize User, :can_manage_user?
  end

  def user_params
    params.require(:user).permit(:role)
  end
end
