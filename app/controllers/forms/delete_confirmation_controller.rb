module Forms
  class DeleteConfirmationController < WebController
    after_action :verify_authorized

    def delete
      authorize current_form

      load_page_variables
    end

    def destroy
      authorize current_form

      load_page_variables
      @delete_confirmation_input = DeleteConfirmationInput.new(delete_confirmation_input_params)

      unless @delete_confirmation_input.valid?
        return render :delete
      end

      unless @delete_confirmation_input.confirmed?
        return redirect_to @back_url
      end

      success_url = current_form.group.present? ? group_path(current_form.group) : root_path

      unless current_form.destroy
        flash[:message] = "Deletion unsuccessful"
        return redirect_to @back_url
      end

      redirect_to success_url, status: :see_other, success: t(".success", form_name: current_form.name)
    end

  private

    def delete_confirmation_input_params
      params.require(:forms_delete_confirmation_input).permit(:confirm)
    end

    def load_page_variables
      @delete_confirmation_input = DeleteConfirmationInput.new

      @url = destroy_form_path(current_form.id)
      @item_name = current_form.name
      @back_url = form_path(current_form.id)
    end
  end
end
