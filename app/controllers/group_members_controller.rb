class GroupMembersController < ApplicationController
  before_action :set_group, :authorize_group_members
  after_action :verify_authorized

  def index; end

private

  def set_group
    @group = Group.find_by(external_id: params[:group_id])
  end

  def authorize_group_members
    authorize @group, :index_users?
  end
end
