class GroupMembersController < ApplicationController
  before_action :set_group
  after_action :verify_authorized

  def index
    authorize @group, :show?
    render locals: { show_actions: show_actions? }
  end

  def new
    authorize @group, :add_editor?
    @group_member_input = GroupMemberInput.new
  end

  def create
    authorize @group, :add_editor?

    @group_member_input = GroupMemberInput.new(group_member_params)
    if @group_member_input.submit
      redirect_to group_members_path(@group.external_id)
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def set_group
    @group = Group.find_by(external_id: params[:group_id])
  end

  def group_member_params
    ## TODO: We are passing in host here because the admin doesn't know it's own URL to use in emails
    params.require(:group_member_input).permit(:member_email_address).merge(group: @group, creator: current_user, host: request.host)
  end

  def show_actions?
    @group.memberships.any? { |membership| policy(membership).update? || policy(membership).destroy? }
  end
end
