module Forms
  class MakeLiveController < ApplicationController
    after_action :verify_authorized

    def new
      authorize current_form, :can_make_form_live?
      @make_live_input = MakeLiveInput.new(form: current_form)
      render_new
    end

    def create
      authorize current_form, :can_make_form_live?

      @make_live_input = MakeLiveInput.new(**make_live_input_params)

      return render_new(status: :unprocessable_entity) unless @make_live_input.valid?
      return redirect_to form_path(@make_live_input.form) unless @make_live_input.confirmed?

      @make_form_live_service = MakeFormLiveService.call(current_form:, current_user:)
      @make_form_live_service.make_live

      render "confirmation", locals: { current_form:, confirmation_page_title: @make_form_live_service.page_title, confirmation_page_body: @make_form_live_service.confirmation_page_body }
    end

  private

    def make_live_input_params
      params.require(:forms_make_live_input).permit(:confirm).merge(form: current_form)
    end

    def render_new(status: :ok)
      if current_form.is_live?
        render "make_your_changes_live", status:, locals: { current_form: }
      elsif current_form.is_archived?
        render "make_archived_draft_live", status:, locals: { current_form: }
      else
        render "make_your_form_live", status:, locals: { current_form: }
      end
    end
  end
end
