require "rails_helper"

describe "authentications/sign_up.html.erb" do
  before do
    render template: "authentications/sign_up"
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content(t("page_titles.sign_up"))
  end

  it "has javascript" do
    expect(view.content_for(:body_end)).to have_selector("script", visible: :all)
  end

  it "has sign_in form" do
    expect(rendered).to have_selector("form[action=\"/auth/#{Settings.auth_provider}/\"]")
  end

  it "has sign_in button" do
    expect(rendered).to have_selector("[data-module=\"sign-in-button\"]")
  end
end
