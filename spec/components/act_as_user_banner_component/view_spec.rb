require "rails_helper"

RSpec.describe ActAsUserBannerComponent::View, type: :component do
  renders_the_user_role = "renders the user role"
  let(:original_user) { create :super_admin_user }
  let(:acting_as_user) { create :user, name: "Stacey Fakename" }

  before do
    render_inline(described_class.new(acting_as_user, original_user))
  end

  context "when given nil as original user" do
    let(:original_user) { nil }

    it "does not render the component" do
      expect(page).not_to have_selector("*")
    end
  end

  context "when the acting as user does not have a name set" do
    let(:acting_as_user) { create :user, :with_no_name, id: 1000 }

    it "renders the user ID" do
      expect(page).to have_text 1000
    end

    context "when the acting as user does not have a organisation set" do
      let(:acting_as_user) { create :user, :with_no_org, id: 1000 }

      it "renders that the user has no organisation set" do
        expect(page).to have_text "with no organisation set"
      end
    end
  end

  it "renders the user name" do
    expect(page).to have_text "Stacey Fakename"
  end

  context "when the user is an organisation admin" do
    let(:acting_as_user) { create :organisation_admin_user }

    it renders_the_user_role do
      expect(page).to have_text(/You are acting as .* an organisation admin/)
    end
  end

  context "when the user is an standard user" do
    let(:acting_as_user) { create :user, role: :standard }

    it renders_the_user_role do
      expect(page).to have_text(/You are acting as .* a standard user/)
    end
  end
end
