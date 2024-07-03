class ActAsUserController < ApplicationController
  before_action :check_act_as_user_is_enabled
  before_action :check_user_super_admin, only: :start

  def start
    target_user = User.find_by(id: params[:user_id])
    act_as(target_user) unless target_user.super_admin?

    redirect_to root_path
  end

  def stop; end

private

  def check_act_as_user_is_enabled
    raise ActionController::RoutingError, "Acting as user not enabled" unless Settings.act_as_user_enabled
  end

  def check_user_super_admin
    raise Pundit::NotAuthorizedError unless current_user.super_admin?
  end

  def act_as(user)
    session[:original_user_id] = current_user.id
    session[:acting_as_user_id] = user.id

    warden.set_user(user)

    @current_user = user
  end
end
