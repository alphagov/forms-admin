class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # GET /groups
  def index
    @active_groups = policy_scope(Group).active
    @trial_groups = policy_scope(Group).trial
  end

  # GET /groups/1
  def show
    authorize @group
    @forms = @group.group_forms.map(&:form)
  end

  # GET /groups/new
  def new
    @group = Group.new
    authorize @group
  end

  # GET /groups/1/edit
  def edit
    authorize @group
  end

  # POST /groups
  def create
    @group = Group.new(group_params)
    @group.organisation = current_user.organisation
    @group.memberships.build(user: current_user, added_by: current_user)

    authorize @group

    if @group.save
      redirect_to @group, success: "Group was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    authorize @group
    if @group.update(group_params)
      redirect_to @group, success: "Group was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    authorize @group
    @group.destroy!
    redirect_to groups_url, success: "Group was successfully deleted.", status: :see_other
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find_by(external_id: params[:group_id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:name)
  end
end
