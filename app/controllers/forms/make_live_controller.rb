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

      already_live = @make_live_form.form.has_live_version

      if @make_live_form.submit
        render_confirmation(already_live ? :changes : :form)
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

    def render_confirmation(made_live)
      @confirmation_page_title = if made_live == :changes
                                   I18n.t("page_titles.your_changes_are_live")
                                 else
                                   I18n.t("page_titles.your_form_is_live")
                                 end

      render "confirmation", locals: { current_form: }
    end

    def user_wants_to_make_form_live
      @make_live_form.valid? && @make_live_form.made_live?
    end
  end
end
