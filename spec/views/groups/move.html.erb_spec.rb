require "rails_helper"

RSpec.describe "groups/move", type: :view do
  let(:group) { create(:group, name: "Blah", status: :active) }
  let(:search_input) { OrganisationSearchInput.new({ organisation_id: current_user.organisation_id }) }

  before do
    assign(:current_user, current_user)
    assign(:group, group)
    assign(:search_input, search_input)

    render
  end

  context "when the user is standard" do
    let(:current_user) { build :user }

    it "does not render the form" do
      expect(rendered).not_to have_select("group[organisation_id]")
    end
  end

  context "when the user is a super admin" do
    let(:current_user) { build :super_admin_user }

    it "shows an organisation selector" do
      expect(rendered).to have_select("group[organisation_id]")
    end
  end
end
