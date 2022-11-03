class Forms::BaseController < ApplicationController
  include CheckFormOrganisation

  def current_form
    Form.find(params[:form_id])
  end

  def append_info_to_payload(payload)
    super
    payload[:form_id] = params[:form_id]
  end

  helper_method :current_form
end
