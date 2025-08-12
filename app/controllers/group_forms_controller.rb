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
      render :new, status: :unprocessable_content
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

    receiving_group = Group.find(group_select_params[:group])
    @group_select = Forms::GroupSelect.new(group: receiving_group, form: form)

    # TODO add spec for checking: compare @group with @group_select.group to check if it's changed
    if @group.external_id == receiving_group.external_id
      flash[:message] = "Form is already in this group."
      render :edit
    else
      success_message = "'#{form.name}' has been moved to '#{receiving_group.name}'"
      form.move_to_group(receiving_group.external_id)

      redirect_to @group, success: success_message, status: :see_other
    end
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
