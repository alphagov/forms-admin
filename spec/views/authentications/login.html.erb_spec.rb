require "rails_helper"

describe "authentications/login.html.erb" do
  before do
    render template: "authentications/login"
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content(t("page_titles.login"))
  end

  it "has javascript" do
    expect(view.content_for(:body_end)).to have_selector("script", visible: :all)
  end

  it "has login form" do
    expect(rendered).to have_selector("form[action=\"/auth/#{Settings.auth_provider}/\"]")
  end
end
