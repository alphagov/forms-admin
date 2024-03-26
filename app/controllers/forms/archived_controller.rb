module Forms
  class ArchivedController < ApplicationController
    after_action :verify_authorized

    def show_form
      authorize current_form, :can_view_form?
      render :show_form, locals: { form_metadata: current_form, form: current_archived_form }
    end

    def show_pages
      authorize current_form, :can_view_form?
      render :show_pages, locals: { form: current_archived_form }
    end

    def current_archived_form
      @current_archived_form ||= Form.find_archived(params[:form_id])
    end
  end
end
