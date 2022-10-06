class Forms::BaseController < ApplicationController
  def current_form
    Form.find(params[:form_id])
  end

  helper_method :current_form
end
