require "rails_helper"

describe HomepageController, type: :request do
  it "redirects to the groups index page" do
    login_as_editor_user
    get root_path

    expect(response).to redirect_to groups_path
  end
end
