module Forms
  class MakeLiveController < BaseController
    def new
      if current_form.live? && !FeatureService.enabled?(:draft_live_versioning)
        redirect_to live_confirmation_url and return
      end

      @make_live_form = MakeLiveForm.new(form: current_form)
      render_new
    end

    def create
      @make_live_form = MakeLiveForm.new(**make_live_form_params)

      if @make_live_form.submit
        if @make_live_form.made_live?
          redirect_to live_confirmation_path(@make_live_form.form)
        else
          redirect_to form_path(@make_live_form.form)
        end
      else
        render_new
      end
    end

    def confirmation
      redirect_to make_live_path if current_form.draft?
      @form = current_form
    end

  private

    def make_live_form_params
      params.require(:forms_make_live_form).permit(:confirm_make_live).merge(form: current_form)
    end

    def render_new
      if current_form.live?
        render "make_your_changes_live"
      else
        render "make_your_form_live"
      end
    end
  end
end
