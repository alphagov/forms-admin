class MasqueradesController < ApplicationController
  before_action :feature_enabled
  before_action :check_not_already_masquerading, only: :show
  before_action :check_user_and_set_masquerade_as, only: :show

  def show
    if @masquerade_as.present?
      masquerade_as(@masquerade_as)
    else
      redirect_to root_path
    end
  end

  def stop
    stop_masquerading
  end

  private

  def feature_enabled
    raise ActionController::RoutingError, "Masquerading feature not enabled" unless masquerading_enabled
  end

  def check_not_already_masquerading
    return redirect_to root_path if session[:masquerading_user_id].present?
  end

  def check_user_and_set_masquerade_as
    return redirect_to root_path unless current_user && current_user.super_admin?

    @masquerade_as = params[:user_id] && User.find_by(id: params[:user_id])
  end
end
