module Forms
  class ArchiveFormController < ApplicationController
    before_action :check_user_has_permission
    after_action :verify_authorized

    def archive
      return redirect_to path_to_form unless current_form.is_live?

      @confirm_archive_input = ConfirmArchiveInput.new(form: current_form)
    end

    def update
      return redirect_to path_to_form unless current_form.is_live?

      @confirm_archive_input = ConfirmArchiveInput.new(confirm_archive_input_params)

      return render :archive unless @confirm_archive_input.valid?
      return redirect_to live_form_path(current_form) unless user_wants_to_archive_form

      current_form.archive!
      redirect_to archive_form_confirmation_path(current_form)
    end

    def confirmation
      render :confirmation, locals: { form: current_form }
    end

  private

    def check_user_has_permission
      authorize current_form, :can_view_form?
    end

    def path_to_form
      FormService.new(current_form).path_for_state
    end

    def confirm_archive_input_params
      params.require(:forms_confirm_archive_input).permit(:confirm).merge(form: current_form)
    end

    def user_wants_to_archive_form
      @confirm_archive_input.confirmed?
    end
  end
end
