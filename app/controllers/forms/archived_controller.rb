module Forms
  class ArchivedController < WebController
    after_action :verify_authorized

    def show_form
      authorize current_form, :can_view_form?

      return redirect_to live_form_path if current_form.is_live?
      raise NotFoundError unless current_form.is_archived?

      render :show_form, locals: { form_metadata: current_form, form_document: current_archived_form, welsh_form_document: }
    end

    def show_pages
      authorize current_form, :can_view_forms?

      return redirect_to live_form_pages_path if current_form.is_live?
      raise NotFoundError unless current_form.is_archived?

      render :show_pages, locals: { form_document: current_archived_form }
    end

  private

    def welsh_form_document
      return nil unless current_archived_form.has_welsh_translation?

      current_archived_welsh_form
    end
  end
end
