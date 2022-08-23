module Forms
  class DeleteConfirmationController < BaseController
    def delete
      load_page_variables
    end

    def destroy
      load_page_variables
      @delete_confirmation_form = DeleteConfirmationForm.new(delete_confirmation_form_params)

      if @delete_confirmation_form.valid?
        if @delete_confirmation_form.confirm_deletion == "true"
          if params[:page_id].present?
            delete_page(@form, @page)
          else
            delete_form(@form)
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

    def delete_confirmation_form_params
      params.require(:forms_delete_confirmation_form).permit(:confirm_deletion)
    end

    def previous_page(id)
      @form.pages.find { |p| p.next_page = id }
    end

    def load_page_variables
      @form = Form.find(params[:form_id])
      @confirm_deletion_options = delete_confirmation_options
      @delete_confirmation_form = DeleteConfirmationForm.new

      if params[:page_id].present?
        @page = Page.find(params[:page_id], params: { form_id: @form.id })
        @url = destroy_page_path(@form, @page)
        @confirm_deletion_legend = t("forms_delete_confirmation_form.confirm_deletion_page")
        @item_name = @page.question_text
        @back_url = edit_page_path(@form, @page)
      else
        @url = destroy_form_path(@form)
        @confirm_deletion_legend = t("forms_delete_confirmation_form.confirm_deletion_form")
        @item_name = @form.name
        @back_url = form_path(@form)
      end
    end

    def delete_form(form)
      success_url = root_path

      if form.destroy
        flash[:message] = "Successfully deleted #{form.name}"
        redirect_to success_url, status: :see_other
      else
        raise StandardError, "Deletion unsuccessful"
      end
    end

    def delete_page(form, page)
      success_url = form_path(form)

      if page.destroy
        flash[:message] = "Successfully deleted #{page.question_text}"
        redirect_to success_url, status: :see_other
      else
        raise StandardError, "Deletion unsuccessful"
      end
    end
  end
end
