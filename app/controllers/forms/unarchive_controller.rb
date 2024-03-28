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

      return redirect_to archived_form_path(current_form) unless user_wants_to_make_form_live

      @make_form_live_service = MakeFormLiveService.call(draft_form: current_form, current_user:)

      if make_form_live
        render "forms/make_live/confirmation", locals: { current_form:, confirmation_page_title: @make_form_live_service.page_title }
      else
        render "unarchive_form", status: :unprocessable_entity, locals: { current_form: }
      end
    end

  private

    def unarchive_form_params
      params.require(:forms_make_live_form).permit(:confirm_make_live).merge(form: current_form)
    end

    def user_wants_to_make_form_live
      @make_live_form.valid? && @make_live_form.made_live?
    end

    def make_form_live
      @make_live_form.valid? && @make_form_live_service.make_live
    end
  end
end
