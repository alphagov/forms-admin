class FormsController < WebController
  after_action :verify_authorized

  def current_form
    @current_form ||= Form.find(params[:form_id])
  end

  def current_live_form
    @current_live_form ||= FormDocument::Content.from_form_document(current_form.live_form_document)
  end

  def current_live_welsh_form
    @current_live_welsh_form ||= FormDocument::Content.from_form_document(current_form.live_welsh_form_document)
  end

  def current_archived_form
    @current_archived_form ||= FormDocument::Content.from_form_document(current_form.archived_form_document)
  end

  def current_archived_welsh_form
    @current_archived_welsh_form ||= FormDocument::Content.from_form_document(current_form.archived_welsh_form_document)
  end
end
