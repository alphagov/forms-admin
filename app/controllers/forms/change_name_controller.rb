module Forms
  class ChangeNameController < ApplicationController
    after_action :verify_authorized, except: :new

    def new
      @change_name_form = ChangeNameForm.new
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
      @change_name_form = ChangeNameForm.new(change_name_form_params(form))

      if @change_name_form.submit
        redirect_to form_path(@change_name_form.form)
      else
        render :new
      end
    end

    def edit
      authorize current_form, :can_view_form?
      @change_name_form = ChangeNameForm.new(form: current_form).assign_form_values
    end

    def update
      authorize current_form, :can_view_form?
      @change_name_form = ChangeNameForm.new(change_name_form_params(current_form))

      if @change_name_form.submit
        redirect_to form_path(@change_name_form.form), success: t("banner.success.form.change_name")
      else
        render :edit
      end
    end

  private

    def change_name_form_params(form)
      params.require(:forms_change_name_form).permit(:name).merge(form:)
    end
  end
end
