module Forms
  class ChangeNameController < ApplicationController
    after_action :verify_authorized, except: :new

    def new
      @name_input = NameInput.new
    end

    def create
      form_args = { name: params[:name], creator_id: @current_user.id }

      # don't set organisation data for forms created by trial users
      if @current_user.trial?
        form_args[:submission_email] = @current_user.email
      else
        form_args[:organisation_id] = @current_user.organisation_id
      end

      form = Form.new(form_args)

      authorize form, :can_view_form?
      @name_input = NameInput.new(name_input_params(form))

      if @name_input.submit
        Form_service.new(form).add_to_default_group!(@current_user)
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
