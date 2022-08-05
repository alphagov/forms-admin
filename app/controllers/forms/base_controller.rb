class Forms::BaseController < ApplicationController
  def current_form
    Form.find(params[:id])
  end

  helper_method :current_form
end
