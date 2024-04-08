require "rails_helper"

RSpec.describe "group_members/index", type: :view do
  let(:organisation) { build(:organisation, slug: "Department for testing group members") }
  let(:user1) { build(:user, organisation:) }
  let(:user2) { build(:user, organisation:) }
  let(:group) { build(:group, name: "Group 1", organisation:) }

  context "when there are members of a group" do
    before do
      create(:membership, user: user1, group:, role: :editor)
      create(:membership, user: user2, group:, role: :group_admin)

      assign(:group, group)
      render
    end

    it "displays the group name" do
      expect(rendered).to have_selector("h1", text: group.name)
    end

    it "displays the page title" do
      expect(rendered).to have_selector("h1", text: t("group_members.index.title"))
    end

    it "displays a table of group memberships" do
      group.memberships.each do |membership|
        expect(rendered).to have_selector("table td", text: membership.user.name)
        expect(rendered).to have_selector("table td", text: membership.user.email)
        expect(rendered).to have_selector("table td", text: t("group_members.index.roles.#{membership.role}.name"))
      end
    end

    it "has a back link to the group page" do
      expect(view.content_for(:back_link)).to have_link("Back to Group 1", href: group_path(group))
    end
  end

  context "when there are no members of a group" do
    before do
      assign(:group, group)
      render
    end

    it "displays a message" do
      expect(rendered).to have_text(t("group_members.index.no_members"))
    end
  end
end
