class MembershipsController < ApplicationController
  before_action :set_membership, only: %i[destroy update]
  after_action :verify_authorized

  def destroy
    authorize @membership

    @membership.destroy!

    redirect_to group_members_path(@membership.group),
                success: t(".success", member_name: @membership.user.name)
  end

  def update
    authorize @membership

    begin
      @membership.update!(membership_params)
      redirect_to group_members_path(@membership.group),
                  success: t(".success.roles.#{@membership.role}", member_name: @membership.user.name)
    rescue ArgumentError
      redirect_to group_members_path(@membership.group)
    end
  end

private

  def set_membership
    @membership = Membership.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:role)
  end
end
