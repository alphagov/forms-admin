module Forms
  class LiveController < WebController
    before_action :check_form_state
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

    def check_form_state
      render template: "errors/not_found", status: :not_found unless current_form.has_live_version
    end
  end
end
