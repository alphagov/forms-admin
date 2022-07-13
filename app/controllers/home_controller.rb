class HomeController < ApplicationController
  def index
    @forms = Form.all(params: { org: current_user.organisation_slug }) || []
  end
end
