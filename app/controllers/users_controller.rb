class UsersController < ApplicationController
  def index
    render template: "users/index", locals: { users: User.all }
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update!(user_params)
    redirect_to users_path
  end

private

  def user_params
    params.require(:user).permit(:role)
  end
end
