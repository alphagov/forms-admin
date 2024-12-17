class GroupFormsController < ApplicationController
  before_action :feature_enabled
  before_action :set_group
  after_action :verify_authorized

  # GET /groups/:group_id/forms/new
  def new
    @group_form = GroupForm.new(group: @group)
    authorize @group_form

    @name_input = Forms::NameInput.new
  end

  # POST /groups/:group_id/forms
  def create
    @group_form = GroupForm.new(group: @group)
    authorize @group_form

    @name_input = Forms::NameInput.new(name_input_params)

    if @name_input.valid?
      @form = FormRepository.create!(creator_id: @current_user.id, name: @name_input.name)
      @group_form.form_id = @form.id
      @group_form.save!

      redirect_to form_path(@form.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def feature_enabled
    raise ActionController::RoutingError, "Groups feature is not enabled" unless groups_enabled
  end

  def set_group
    @group = Group.find_by!(external_id: params[:group_id])
  end

  def name_input_params
    params.require(:forms_name_input).permit(:name)
  end
end
