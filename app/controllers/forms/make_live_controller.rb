module Forms
  class MakeLiveController < BaseController
    after_action :verify_authorized
    def new
      authorize current_form, :can_make_form_live?
      @make_live_form = MakeLiveForm.new(form: current_form)
      render_new
    end

    def create
      authorize current_form, :can_make_form_live?

      @make_live_form = MakeLiveForm.new(**make_live_form_params)
      already_live = @make_live_form.form.has_live_version

      if @make_live_form.submit
        if @make_live_form.made_live?
          render_confirmation(already_live ? :changes : :form)
        else
          redirect_to form_path(@make_live_form.form)
        end
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
        render "make_your_changes_live"
      else
        render "make_your_form_live"
      end
    end

    def render_confirmation(made_live)
      @form = current_form
      @confirmation_page_title = if made_live == :changes
                                   I18n.t("page_titles.your_changes_are_live")
                                 else
                                   I18n.t("page_titles.your_form_is_live")
                                 end

      render "confirmation"
    end
  end
end
