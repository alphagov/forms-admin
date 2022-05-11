class HomeController < ApplicationController
  def index
    @forms = Form.all
  end
end
