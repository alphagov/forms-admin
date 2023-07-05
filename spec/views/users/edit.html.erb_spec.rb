require "rails_helper"

describe "users/edit.html.erb" do
  let(:user) do
    build :user, role: :editor, id: 1
  end

  before do
    create :organisation, slug: "test-org"
    create :organisation, slug: "ministry-of-testing"
    create :organisation, slug: "department-for-tests"

    assign(:user, user)
    render template: "users/edit"
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: /Edit user/)
  end

  describe "summary list" do
    let(:summary_list) do
      Capybara.string(rendered).find(".govuk-summary-list")
    end

    it "contains name" do
      expect(summary_list).to have_text(user.name)
    end

    it "contains email" do
      expect(summary_list).to have_text(user.email)
    end

    it "contains organisation slug from GOV.UK Signon" do
      expect(summary_list).to have_text(user.organisation_slug)
    end

    it "contains organisation name" do
      expect(rendered).to have_text(user.organisation.name)
    end

    it "contains role" do
      expect(summary_list).to have_text("Editor")
    end

    it "contains access" do
      expect(summary_list).to have_text("Permitted")
    end
  end

  describe "form" do
    it "has role fields" do
      expect(rendered).to have_checked_field("Editor")
      expect(rendered).to have_unchecked_field("Super admin")
      expect(rendered).to have_unchecked_field("Trial")
    end

    it "has organisation fields" do
      expect(rendered).to have_select(
        "Organisation", selected: "Test Org", with_options: ["Department For Tests", "Ministry Of Testing", "Test Org"]
      )
    end

    it "has access fields" do
      expect(rendered).to have_checked_field("Permitted")
      expect(rendered).to have_unchecked_field("Denied")
    end
  end

  context "with a user with an unknown organisation" do
    let(:user) { build(:user, :with_unknown_org, role: :editor, id: 1) }

    it "shows the organisation slug" do
      expect(rendered).to have_text("unknown-org")
    end

    it "shows no organisation set" do
      expect(rendered).to have_text("No organisation set")
    end

    it "prompts super admin to choose organisation" do
      expect(rendered).to have_select("Organisation", with_options: ["Select an organisation"])
    end
  end

  context "with a user with no organisation set" do
    let(:user) { build(:user, :with_no_org, role: :editor, id: 1) }

    it "shows no organisation set" do
      expect(rendered).to have_text("No organisation set")
    end

    it "prompts super admin to choose organisation" do
      expect(rendered).to have_select("Organisation", with_options: ["Select an organisation"])
    end
  end
end
