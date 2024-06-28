class HomepageController < ApplicationController
  def index
    redirect_to groups_path
  end
end
