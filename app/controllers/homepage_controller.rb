class HomepageController < ApplicationController
  def index
    if groups_enabled
      redirect_to groups_path
    else
      FormsController.dispatch(:index, request, response)
    end
  end
end
