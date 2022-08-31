module Forms
  class MakeLiveController < BaseController
    def new
      redirect_to live_confirmation_url if current_form.live_at.present?
      @make_live_form = MakeLiveForm.new(form: current_form)
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
        render :new
      end
    end

    def confirmation
      redirect_to make_live_path if current_form.live_at.blank?
    end

  private

    def make_live_form_params
      params.require(:forms_make_live_form).permit(:confirm_make_live).merge(form: current_form)
    end
  end
end
