class UsersController < ApplicationController
  def index
    render template: "users/index", locals: { users: User.all }
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.super_admin_user = user_params[:super_admin_user]
    @user.save!
    redirect_to users_path
  end

private

  def user_params
    params.require(:user).permit(:super_admin_user)
  end
end
