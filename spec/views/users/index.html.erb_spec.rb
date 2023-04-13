require "rails_helper"

describe "users/index.html.erb" do
  let(:users) do
    build_list(:user, 3) do |user, i|
      user.id = i
    end
  end

  before do
    render template: "users/index", locals: { users: }
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: /Users/)
  end

  it "contains a link to edit with name" do
    expect(rendered).to have_link(users.first.name, href: edit_user_path(users.first))
  end

  it "contains email" do
    expect(rendered).to have_text(users.first.email)
  end

  it "contains org" do
    expect(rendered).to have_text(users.first.organisation_slug)
  end

  it "contains role" do
    expect(rendered).to have_text("Editor")
  end
end
