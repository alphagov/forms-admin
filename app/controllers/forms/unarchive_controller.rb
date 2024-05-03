module Forms
  class UnarchiveController < ApplicationController
    after_action :verify_authorized

    def new
      authorize current_form, :can_make_form_live?
      @make_live_input = MakeLiveInput.new(form: current_form)
      render "unarchive_form", locals: { current_form: }
    end

    def create
      authorize current_form, :can_make_form_live?

      @make_live_input = MakeLiveInput.new(**unarchive_form_params)

      return render "unarchive_form", status: :unprocessable_entity, locals: { current_form: } unless @make_live_input.valid?
      return redirect_to archived_form_path(current_form) unless @make_live_input.confirmed?

      @make_form_live_service = MakeFormLiveService.call(current_form:, current_user:)
      @make_form_live_service.make_live

      render "forms/make_live/confirmation", locals: { current_form:, confirmation_page_title: @make_form_live_service.page_title }
    end

  private

    def unarchive_form_params
      params.require(:forms_make_live_input).permit(:confirm).merge(form: current_form)
    end
  end
end
