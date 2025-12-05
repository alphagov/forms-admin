module Forms
  class CopyController < WebController
    after_action :verify_authorized

    def copy
      authorize current_form, :copy?

      @copy_input = Forms::CopyInput.new(form: current_form).assign_form_values

      render :confirm
    end
  end
end
