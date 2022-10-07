class Forms::BaseController < ApplicationController
  include CheckFormOrganisation

  def current_form
    Form.find(params[:form_id])
  end

  helper_method :current_form
end
