class AuthenticationController < ApplicationController
  include GDS::SSO::ControllerMethods

  before_action :authenticate_user!, only: :callback

  layout false

  def callback
    logger.debug("custom authentication callback action reached")
    redirect_to session["return_to"] || "/"
  end
end
