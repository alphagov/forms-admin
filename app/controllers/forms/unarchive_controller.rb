module Forms
  class UnarchiveController < ApplicationController
    after_action :verify_authorized

    def new
      authorize current_form, :can_make_form_live?
      @make_live_form = MakeLiveForm.new(form: current_form)
      render "unarchive_form", locals: { current_form: }
    end

    def create
      authorize current_form, :can_make_form_live?

      @make_live_form = MakeLiveForm.new(**unarchive_form_params)

      return redirect_to archived_form_path(current_form) unless @make_live_form.user_wants_to_make_form_live

      @make_form_live_service = MakeFormLiveService.call(current_form:, current_user:)

      if @make_live_form.make_form_live(@make_form_live_service)
        render "forms/make_live/confirmation", locals: { current_form:, confirmation_page_title: @make_form_live_service.page_title }
      else
        render "unarchive_form", status: :unprocessable_entity, locals: { current_form: }
      end
    end

  private

    def unarchive_form_params
      params.require(:forms_make_live_form).permit(:confirm).merge(form: current_form)
    end
  end
end
