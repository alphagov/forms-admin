module Forms
  class WhatHappensNextController < BaseController
    after_action :verify_authorized
    def new
      authorize current_form, :can_view_form?
      @what_happens_next_form = WhatHappensNextForm.new(form: current_form).assign_form_values
    end

    def create
      authorize current_form, :can_view_form?
      @what_happens_next_form = WhatHappensNextForm.new(**what_happens_next_form_params)

      if @what_happens_next_form.submit
        redirect_to form_path(@what_happens_next_form.form), success: t("banner.success.form.what_happens_next_saved")
      else
        render :new
      end
    end

  private

    def what_happens_next_form_params
      params.require(:forms_what_happens_next_form).permit(:what_happens_next_text).merge(form: current_form)
    end
  end
end
