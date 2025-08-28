module Forms
  class LiveController < ApplicationController
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
      @current_live_form ||= FormRepository.find_live(form_id: params[:form_id])
    end
  end
end
