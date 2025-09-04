module Forms
  class LiveController < WebController
    after_action :verify_authorized

    def show_form
      authorize current_form, :can_view_form?
      render :show_form, locals: { form_metadata: current_form, form_document: current_live_form }
    end

    def show_pages
      authorize current_form, :can_view_form?
      render :show_pages, locals: { form_document: current_live_form }
    end

  private

    def current_live_form
      @current_live_form ||= FormDocument::Content.from_form_document(current_form.live_form_document)
    end
  end
end
