class GroupFormsController < ApplicationController
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
      @form = CreateFormService.new.create!(creator: @current_user, group: @group, name: @name_input.name)

      redirect_to form_path(@form.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @group_form = GroupForm.find_by(form_id: params[:id])
    authorize @group_form

    form = FormRepository.find(form_id: @group_form.form_id)

    @group_select = Forms::GroupSelect.new(group: @group, form: form)
  end

  def update
    @group_form = GroupForm.find_by(form_id: params[:id])
    authorize @group_form

    form = Form.find(params[:id])
    @group_select = Forms::GroupSelect.new(group: group_select_params[:group], form: form)

    receiving_group = Group.find(@group_select.group)
    form.move_to_group(receiving_group.external_id)
    form.reload

    redirect_to group_path(params[:group_id])
  end

private

  def set_group
    @group = Group.find_by!(external_id: params[:group_id])
  end

  def group_select_params
    params.require(:forms_group_select).permit(:group)
  end

  def name_input_params
    params.require(:forms_name_input).permit(:name)
  end
end
