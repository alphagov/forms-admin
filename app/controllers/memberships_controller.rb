class MembershipsController < ApplicationController
  after_action :verify_authorized

  def destroy
    membership = Membership.find(params[:id])
    authorize membership

    membership.destroy!

    success_message = t(".success", member_name: membership.user.name)
    redirect_to group_members_path(membership.group), success: success_message
  end
end
