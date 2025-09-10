class Api::FormDocumentsController < ApplicationController
  def show
    render json: get_form_document
  end

  def get_form_document
    FormDocument.find_by!(form_id: params[:form_id], tag: params[:tag]).content
  end
end
