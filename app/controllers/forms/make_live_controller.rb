module Forms
  class MakeLiveController < ApplicationController
    after_action :verify_authorized
    def new
      authorize current_form, :can_make_form_live?
      @make_live_form = MakeLiveForm.new(form: current_form)
      render_new
    end

    def create
      authorize current_form, :can_make_form_live?

      @make_live_form = MakeLiveForm.new(**make_live_form_params)

      return redirect_to form_path(@make_live_form.form) unless user_wants_to_make_form_live

      @make_form_live_service = MakeFormLiveService.call(draft_form: current_form, current_user:)

      if make_form_live
        render "confirmation", locals: { current_form:, confirmation_page_title: @make_form_live_service.page_title }
      else
        render_new
      end
    end

  private

    def make_live_form_params
      params.require(:forms_make_live_form).permit(:confirm_make_live).merge(form: current_form)
    end

    def render_new
      if current_form.has_live_version
        render "make_your_changes_live", locals: { current_form: }
      else
        render "make_your_form_live", locals: { current_form: }
      end
    end

    def user_wants_to_make_form_live
      @make_live_form.valid? && @make_live_form.made_live?
    end

    def make_form_live
      @make_live_form.valid? && @make_form_live_service.make_live
    end
  end
end
