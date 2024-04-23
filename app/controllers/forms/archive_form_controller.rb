module Forms
  class ArchiveFormController < ApplicationController
    before_action :check_user_has_permission
    after_action :verify_authorized

    # TODO: rename to new - see MakeLiveController
    def archive
      return redirect_to path_to_form unless current_form.is_live?

      @confirm_archive_form = ConfirmArchiveForm.new(form: current_form)
    end

    # TODO: rename to create - see MakeLiveController
    def update
      return redirect_to path_to_form unless current_form.is_live?

      @confirm_archive_form = ConfirmArchiveForm.new(confirm_archive_form_params)

      return render :archive unless @confirm_archive_form.valid?
      return redirect_to live_form_path(current_form) unless user_wants_to_archive_form

      current_form.archive!
      SubmissionEmailMailer.alert_processor_form_archive(processor_email: current_form.submission_email,
                                                         form_name: current_form.name,
                                                         creator_name: current_user.name,
                                                         creator_email: current_user.email)

      form_archiver = ArchiveFormService.new
      form_archiver.archive_form(current_form, current_user)

      # TODO: Refactor to use a service object and wrap the above (see MakeLiveController and MakeFormLiveService) ☝️
      # TODO: see make_live_controller.rb for more things to do...
      redirect_to archive_form_confirmation_path(current_form)
    end

    # TODO: remove this method and move the render into the create above - see MakeLiveController
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

    def confirm_archive_form_params
      params.require(:forms_confirm_archive_form).permit(:confirm).merge(form: current_form)
    end

    def user_wants_to_archive_form
      @confirm_archive_form.confirmed?
    end
  end
end
