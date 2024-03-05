class GroupFormsController < ApplicationController
  before_action :set_group
  after_action :verify_authorized

  # GET /groups/:group_id/forms/new
  def new
    @group_form = GroupForm.new(group: @group)
    authorize @group_form

    @name_form = Forms::NameForm.new
  end

  # POST /groups/:group_id/forms
  def create
    @group_form = GroupForm.new(group: @group)
    authorize @group_form

    @form = Form.new(creator_id: @current_user.id)
    @name_form = Forms::NameForm.new(name_form_params(@form))

    if @name_form.submit
      @group_form.form_id = @form.id
      @group_form.save!

      redirect_to form_path(@form)
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def set_group
    @group = Group.find_by(external_id: params[:group_id])
  end

  def name_form_params(form)
    params.require(:forms_name_form).permit(:name).merge(form:)
  end
end
