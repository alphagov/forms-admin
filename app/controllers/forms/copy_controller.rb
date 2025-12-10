module Forms
  class CopyController < WebController
    after_action :verify_authorized

    def copy
      authorize current_form, :copy?

      @copy_input = Forms::CopyInput.new(form: current_form).assign_form_values

      render :confirm
    end

    def create
      authorize current_form, :copy?
      @copy_input = Forms::CopyInput.new(copy_input_params(current_form))

      if @copy_input.submit
        copied_form = FormCopyService.new(current_form, current_user).copy
        copied_form.update!(name: @copy_input.name)
        redirect_to form_path(copied_form.id), success: t("banner.success.form.copied")
      else
        render :confirm
      end
    end

  private

    def copy_input_params(form)
      params.require(:forms_copy_input).permit(:name).merge(form:)
    end
  end
end
