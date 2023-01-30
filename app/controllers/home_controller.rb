class HomeController < ApplicationController
  def index
    @forms = Form.all(params: { org: user_information.organisation_slug }).sort_by(&:name) || []
  end
end
