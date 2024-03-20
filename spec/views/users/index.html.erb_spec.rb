require "rails_helper"

describe "users/index.html.erb" do
  let(:users) do
    build_list(:user, 3) do |user, i|
      user.id = i
      user.role = :editor
    end
  end

  before do
    render template: "users/index", locals: { users: }
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: /Users/)
  end

  it "contains the user's name" do
    expect(rendered).to have_text(users.first.name)
  end

  it "contains the user's email as a link to the edit page" do
    expect(rendered).to have_link(users.first.email, href: edit_user_path(users.first))
  end

  it "contains organisation name" do
    expect(rendered).to have_text(users.first.organisation.name)
  end

  it "contains role" do
    expect(rendered).to have_text("Editor")
  end

  it "contains access" do
    expect(rendered).to have_text("Permitted")
  end

  context "with a user with no name set" do
    let(:users) { [build(:user, :with_no_name, id: 1)] }

    it "shows no name set" do
      expect(rendered).to have_text("No name set")
    end
  end

  context "with a user with an unknown organisation" do
    let(:users) { [build(:user, :with_unknown_org, id: 1)] }

    it "shows no organisation set" do
      expect(rendered).to have_text("No organisation set")
    end
  end

  context "with a user with no organisation set" do
    let(:users) { [build(:user, :with_no_org, id: 1)] }

    it "shows no organisation set" do
      expect(rendered).to have_text("No organisation set")
    end
  end
end
