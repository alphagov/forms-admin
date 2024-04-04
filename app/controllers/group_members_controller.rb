class GroupMembersController < ApplicationController
  before_action :set_group

  def index; end

private

  def set_group
    @group = Group.find_by(external_id: params[:group_id])
  end
end
