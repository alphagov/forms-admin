require "rails_helper"

describe "users/edit.html.erb" do
  let(:user) do
    build :user, id: 1
  end

  before do
    assign(:user, user)
    render template: "users/edit", layout: "layouts/application"
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: /Edit user/)
  end

  it "contains name" do
    expect(rendered).to have_text(user.name)
  end

  it "contains email" do
    expect(rendered).to have_text(user.email)
  end

  it "contains org" do
    expect(rendered).to have_text(user.organisation_slug)
  end

  it "has form fields" do
    expect(rendered).to have_checked_field("Editor")
    expect(rendered).to have_unchecked_field("Super admin")
  end
end
