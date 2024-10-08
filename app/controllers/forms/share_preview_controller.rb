module Forms
  class SharePreviewController < ApplicationController
    before_action :check_user_has_permission
    after_action :verify_authorized

    def new
      @share_preview_input = Forms::SharePreviewInput.new(form: current_form).assign_form_values
    end

    def create
      @share_preview_input = Forms::SharePreviewInput.new(mark_complete_input_params)

      if @share_preview_input.submit
        redirect_to form_path(current_form)
      else
        render "new", status: :unprocessable_entity
      end
    end

    def check_user_has_permission
      authorize current_form, :can_view_form?
    end

    def mark_complete_input_params
      params.require(:forms_share_preview_input).permit(:mark_complete).merge(form: current_form)
    end
  end
end
