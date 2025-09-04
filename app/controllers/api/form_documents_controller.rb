class Api::FormDocumentsController < ApplicationController
  def show
    render json: get_form_document
  end

  def get_form_document
    if params[:tag] == "draft"
      return Form.find(params[:form_id]).as_form_document
    end

    FormDocument.find_by!(form_id: params[:form_id], tag: params[:tag]).content
  end
end
