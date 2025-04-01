require "rails_helper"

RSpec.describe BreadcrumbsHelper, type: :helper do
  describe "#groups_breadcrumb" do
    it "links to the groups page" do
      assign(:current_user, build(:user))
      assign(:group, build(:group))
      expect(helper.groups_breadcrumb).to eq({
        "Your groups" => "/groups",
      })
    end

    context "when user is viewing a group in a different organisation" do
      before do
        organisation = build :organisation
        other_organisation = build :organisation, id: 101, slug: "other-organisation"
        assign(:current_user, build(:user, organisation:))
        assign(:group, build(:group, organisation: other_organisation))
      end

      it "links to the groups for that organisation" do
        expect(helper.groups_breadcrumb).to eq({
          "Other Organisation’s groups" => "/groups?search%5Borganisation_id%5D=101",
        })
      end
    end
  end
end
