class Forms::BaseController < ApplicationController
  def current_form
    @current_form ||= Form.find(params[:form_id])
  end
end
