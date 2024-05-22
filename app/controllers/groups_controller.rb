class GroupsController < ApplicationController
  before_action :set_group, except: %i[index new create]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # GET /groups
  def index
    @active_groups = policy_scope(Group).active
    @upgrade_requested_groups = policy_scope(Group).upgrade_requested
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
    @group = Group.new(group_params.merge({ creator: @current_user }))
    @group.organisation = current_user.organisation
    @group.memberships.build(user: current_user, added_by: current_user, role: :group_admin)

    authorize @group

    if @group.save
      redirect_to @group, success: t("groups.success_messages.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    authorize @group
    if @group.update(group_params)
      redirect_to @group, success: t("groups.success_messages.update"), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def confirm_upgrade
    authorize @group, :upgrade?
    @confirm_upgrade_input = Groups::ConfirmUpgradeInput.new
  end

  def upgrade
    authorize @group

    @confirm_upgrade_input = Groups::ConfirmUpgradeInput.new(confirm_upgrade_input_params)
    return render :confirm_upgrade, status: :unprocessable_entity unless @confirm_upgrade_input.valid?
    return redirect_to @group unless @confirm_upgrade_input.confirmed?

    GroupService.new(group: @group, current_user: @current_user, host: request.host).upgrade_group

    redirect_to @group, success: t("groups.success_messages.upgrade"), status: :see_other
  end

  def confirm_upgrade_request
    authorize @group, :request_upgrade?
  end

  def request_upgrade
    authorize @group, :request_upgrade?

    GroupService.new(group: @group, current_user: @current_user, host: request.host).request_upgrade

    render :upgrade_requested
  end

  def review_upgrade
    authorize @group, :review_upgrade?
    @confirm_upgrade_input = Groups::ConfirmUpgradeInput.new
  end

  def submit_review_upgrade
    authorize @group, :review_upgrade?

    @confirm_upgrade_input = Groups::ConfirmUpgradeInput.new(confirm_upgrade_input_params)

    return render :review_upgrade, status: :unprocessable_entity unless @confirm_upgrade_input.valid?

    group_service = GroupService.new(group: @group, current_user: @current_user, host: request.host)
    if @confirm_upgrade_input.confirmed?
      group_service.upgrade_group
      redirect_to @group, success: t("groups.success_messages.upgrade"), status: :see_other
    else
      group_service.reject_upgrade
      redirect_to @group, status: :see_other
    end
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find_by!(external_id: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:name)
  end

  def confirm_upgrade_input_params
    params.require(:groups_confirm_upgrade_input).permit(:confirm)
  end
end
