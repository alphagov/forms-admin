module Forms
  class ArchivedController < WebController
    before_action :check_form_state
    after_action :verify_authorized

    def show_form
      authorize current_form, :can_view_form?
      render :show_form, locals: { form_metadata: current_form, form_document: current_archived_form }
    end

    def show_pages
      authorize current_form, :can_view_form?
      render :show_pages, locals: { form_document: current_archived_form }
    end

    def current_archived_form
      @current_archived_form ||= FormDocument::Content.from_form_document(current_form.archived_form_document)
    end

  private

    def check_form_state
      render template: "errors/not_found", status: :not_found unless current_form.has_been_archived
    end
  end
end
