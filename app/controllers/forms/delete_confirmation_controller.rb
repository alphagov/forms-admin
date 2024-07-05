module Forms
  class DeleteConfirmationController < ApplicationController
    after_action :verify_authorized

    def delete
      load_page_variables
    end

    def destroy
      load_page_variables
      @delete_confirmation_input = DeleteConfirmationInput.new(delete_confirmation_input_params)

      if @delete_confirmation_input.valid?
        if @delete_confirmation_input.confirmed?
          if params[:page_id].present?
            delete_page(current_form, @page)
          else
            delete_form(current_form)
          end
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

    def delete_confirmation_options
      [
        OpenStruct.new(value: "true"),
        OpenStruct.new(value: "false"),
      ]
    end

    def delete_confirmation_input_params
      params.require(:forms_delete_confirmation_input).permit(:confirm)
    end

    def previous_page(id)
      current_form.pages.find { |p| p.next_page = id }
    end

    def load_page_variables
      @delete_confirmation_input = DeleteConfirmationInput.new

      if params[:page_id].present?
        @page = Page.find(params[:page_id], params: { form_id: current_form.id })
        @url = destroy_page_path(current_form, @page)
        @confirm_deletion_legend = t("forms_delete_confirmation_input.confirm_deletion_page")
        @item_name = @page.question_text
        @back_url = edit_question_path(current_form, @page)
      else
        @url = destroy_form_path(current_form)
        @confirm_deletion_legend = t("forms_delete_confirmation_input.confirm_deletion")
        @confirm_deletion_live_form = t("forms_delete_confirmation_input.confirm_deletion_live_form") if current_form.live?
        @item_name = current_form.name
        @back_url = form_path(current_form)
      end
    end

    def delete_form(form)
      success_url = groups_enabled && form.group.present? ? group_path(form.group) : root_path

      authorize form, :can_view_form?
      if form.destroy
        redirect_to success_url, status: :see_other, success: "Successfully deleted ‘#{form.name}’"
      else
        raise StandardError, "Deletion unsuccessful"
      end
    end

    def delete_page(form, page)
      success_url = form_pages_path(form)

      authorize form, :can_view_form?
      if page.destroy
        redirect_to success_url, status: :see_other, success: "Successfully deleted ‘#{page.question_text}’"
      else
        raise StandardError, "Deletion unsuccessful"
      end
    end
  end
end
