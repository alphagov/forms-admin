module Forms
  class ChangeNameController < ApplicationController
    after_action :verify_authorized, except: :new

    def new
      @name_input = NameInput.new
    end

    def create
      form = Form.new(name: params[:name], creator_id: @current_user.id)

      form_service = FormService.new(form)
      form_service.assign_owner!(@current_user)

      authorize form, :can_view_form?
      @name_input = NameInput.new(name_input_params(form))

      if @name_input.submit
        form_service.add_to_default_group!(@current_user)
        redirect_to form_path(@name_input.form)
      else
        render :new
      end
    end

    def edit
      authorize current_form, :can_view_form?
      @name_input = NameInput.new(form: current_form).assign_form_values
    end

    def update
      authorize current_form, :can_view_form?
      @name_input = NameInput.new(name_input_params(current_form))

      if @name_input.submit
        redirect_to form_path(@name_input.form), success: t("banner.success.form.change_name")
      else
        render :edit
      end
    end

  private

    def name_input_params(form)
      params.require(:forms_name_input).permit(:name).merge(form:)
    end
  end
end
