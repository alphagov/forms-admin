class GroupMembersController < ApplicationController
  before_action :set_group, :authorize_group_members
  after_action :verify_authorized

  def index
    authorize @group, :show?
  end

  def new; end

private

  def set_group
    @group = Group.find_by(external_id: params[:group_id])
  end

  def group_member_params
    params.require(:group_member_form).permit(:member_email_address).merge(group: @group, creator: current_user)
  end
end
