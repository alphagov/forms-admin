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

      return render :delete unless @delete_confirmation_input.valid?
      return redirect_to @back_url unless @delete_confirmation_input.confirmed?

      result = delete_form_or_draft

      if result[:success]
        redirect_to result[:redirect_url],
                    status: :see_other,
                    success: t(".success", form_name: current_form.name)
      # if not in a state we can delete in, redirect back with a failure message
      else
        flash[:message] = t(".failure")
        redirect_to @back_url
      end
    end

  private

    def delete_form_or_draft
      # We allow deleting a live form because the end to end tests use it to clear up forms.
      # Real users are not intended to delete live forms and we don't show the button on live forms.
      if current_form.draft? || current_form.live?
        success_url = group_path(current_form.group)
        success = current_form.destroy
        { success: success, redirect_url: success_url }
      elsif current_form.live_with_draft?
        success_url = live_form_path(current_form.id)
        success = RevertDraftFormService.new(current_form).revert_draft_from_form_document(:live)
        { success: success, redirect_url: success_url }
      else
        { success: false }
      end
    end

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
