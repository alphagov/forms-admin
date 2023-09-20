class UserUpgradeRequestsController < ApplicationController
  def new
    @user_upgrade_request = UserUpgradeRequest.new
  end

  def show; end

  def create
    @user_upgrade_request = UserUpgradeRequest.new(user_upgrade_request_params)

    if @user_upgrade_request.valid?
      UserUpgradeRequestService.new(current_user).request_upgrade

      redirect_to user_upgrade_request_sent_path
    else
      render :new
    end
  end

  def user_upgrade_request_params
    params.require(:user_upgrade_request).permit(:met_requirements)
  end
end
