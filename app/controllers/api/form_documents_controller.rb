class Api::FormDocumentsController < ApplicationController
  def show
    render json: form_document.content
  end

private

  def form_document
    @form_document ||= FormDocument.find_by!(form_document_params)
  end

  def form_document_params
    permitted_params = params.permit(:form_id, :tag, :language)

    # default language to "en" if not given
    permitted_params[:language] ||= "en"

    permitted_params
  end
end
