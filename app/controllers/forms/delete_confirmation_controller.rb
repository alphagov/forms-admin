module Forms
  class DeleteConfirmationController < ApplicationController
    after_action :verify_authorized

    def delete
      authorize current_form

      load_page_variables
    end

    def destroy
      authorize current_form

      load_page_variables
      @delete_confirmation_input = DeleteConfirmationInput.new(delete_confirmation_input_params)

      if @delete_confirmation_input.valid?
        if @delete_confirmation_input.confirmed?
          delete_form(current_form)
        else
          redirect_to @back_url
        end
      else
        render :delete
      end
    rescue StandardError
      flash[:message] = "Deletion unsuccessful"
      redirect_to @back_url
    end

  private

    def delete_confirmation_input_params
      params.require(:forms_delete_confirmation_input).permit(:confirm)
    end

    def load_page_variables
      @delete_confirmation_input = DeleteConfirmationInput.new

      @url = destroy_form_path(current_form)
      @confirm_deletion_legend = t("forms_delete_confirmation_input.confirm_deletion")
      @item_name = current_form.name
      @back_url = form_path(current_form)
    end

    def delete_form(form)
      success_url = groups_enabled && form.group.present? ? group_path(form.group) : root_path

      if form.destroy
        redirect_to success_url, status: :see_other, success: "Successfully deleted ‘#{form.name}’"
      else
        raise StandardError, "Deletion unsuccessful"
      end
    end
  end
end
