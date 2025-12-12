module Forms
  class CopyController < WebController
    after_action :verify_authorized

    def copy
      authorize current_form, :copy?

      form = if tag == "live"
               current_live_form
             elsif tag == "archived"
               current_archived_form
             else
               current_form
             end

      @copy_input = Forms::CopyInput.new(form: form, tag: tag).assign_form_values

      render :confirm
    end

    def create
      authorize current_form, :copy?
      @copy_input = Forms::CopyInput.new(copy_input_params(current_form))

      if @copy_input.submit
        copied_form = FormCopyService.new(current_form, current_user).copy(tag: @copy_input.tag)
        copied_form.update!(name: @copy_input.name)
        redirect_to form_path(copied_form.id), success: t("banner.success.form.copied")
      else
        render :confirm
      end
    end

  private

    def copy_input_params(form)
      params.require(:forms_copy_input).permit(:name, :tag).merge(form:)
    end

    def tag
      return "draft" if params[:tag].blank?

      params[:tag]
    end
  end
end
