require "rails_helper"

describe "authentications/sign_in.html.erb" do
  before do
    render template: "authentications/sign_in"
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content(t("page_titles.sign_in"))
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

  context "when @is_e2e_user is true" do
    before do
      assign(:is_e2e_user, true)
      render template: "authentications/sign_in"
    end

    it "has e2e sign_in button" do
      expect(rendered).to have_selector("input[type=\"hidden\"][name=\"connection\"][value=\"Username-Password-Authentication\"]", visible: :all)
    end
  end
end
