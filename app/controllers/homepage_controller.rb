class HomepageController < ApplicationController
  def index
    if FeatureService.new(current_user).enabled? :groups
      redirect_to groups_path
    else
      FormsController.dispatch(:index, request, response)
    end
  end
end
