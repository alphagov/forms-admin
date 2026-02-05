module Forms
  class LiveController < WebController
    after_action :verify_authorized

    def show_form
      authorize current_form, :can_view_form?

      return redirect_to archived_form_path if current_form.is_archived?
      raise NotFoundError unless current_form.is_live?

      render :show_form, locals: { form_metadata: current_form, form_document: current_live_form, welsh_form_document: }
    end

    def show_pages
      authorize current_form, :can_view_form?

      return redirect_to archived_form_pages_path if current_form.is_archived?
      raise NotFoundError unless current_form.is_live?

      render :show_pages, locals: { form_document: current_live_form }
    end

  private

    def welsh_form_document
      return nil unless current_live_form.has_welsh_translation?

      current_live_welsh_form
    end
  end
end
