require "rails_helper"

RSpec.describe BreadcrumbsHelper, type: :helper do
  describe "#breadcrumbs" do
    it "returns a hash of breadcrumbs" do
      expect(helper.breadcrumbs).to match({ breadcrumbs: a_kind_of(Hash) })
    end

    it "returns link text and href for a breadcrumb" do
      expect(helper.breadcrumbs(:groups)).to eq({ breadcrumbs: { "Your groups" => "/groups" } })
    end

    it "passes keyword arguments to breadcrumb helpers" do
      group = build :group, external_id: "foo", name: "Crumbly group"
      expect(helper.breadcrumbs(:group, group:)).to eq({ breadcrumbs: { "Crumbly group" => group_path(group) } })
    end

    it "adds each breadcrumb in order" do
      group = build :group, external_id: "baz", name: "Test group"
      form = build :form, id: 10, name: "Test form"

      expect(helper.breadcrumbs(:groups, :group, :form, group:, form:)[:breadcrumbs].to_a).to eq([
        ["Your groups", "/groups"],
        ["Test group", "/groups/baz"],
        ["Test form", "/forms/10"],
      ])
    end
  end

  describe "#groups_breadcrumb" do
    it "links to the groups page" do
      expect(helper.groups_breadcrumb).to eq({
        "Your groups" => "/groups",
      })
    end

    context "when user is viewing a group in a different organisation" do
      before do
        organisation = build :organisation
        assign(:current_user, build(:user, organisation:))
      end

      it "links to the groups for that organisation" do
        other_organisation = build :organisation, id: 101, slug: "other-organisation"
        expect(helper.groups_breadcrumb(other_organisation)).to eq({
          "Other Organisation’s groups" => "/groups?search%5Borganisation_id%5D=101",
        })
      end
    end
  end
end
