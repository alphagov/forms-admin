require "rails_helper"

RSpec.describe "group_members/index", type: :view do
  let(:organisation) { build(:organisation, slug: "Department for testing group members") }
  let(:user1) { build(:user, organisation:) }
  let(:user2) { build(:user, organisation:) }
  let(:group) { create(:group, name: "Group 1", organisation:) }
  let(:add_editor) { false }

  before do
    assign(:group, group)

    allow(Pundit).to receive(:policy).and_return(instance_double(GroupPolicy, add_editor?: add_editor))
  end

  context "when there are members of a group" do
    before do
      create(:membership, user: user1, group:, role: :editor)
      create(:membership, user: user2, group:, role: :group_admin)

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

    it "does not display a link to add a member" do
      expect(rendered).not_to have_link(href: new_group_member_path(group))
    end

    context "when the current user can add an editor" do
      let(:add_editor) { true }

      it "displays a link to add a member" do
        expect(rendered).to have_link(t("group_members.index.add_member"), href: new_group_member_path(group))
      end
    end
  end

  context "when there are no members of a group" do
    before do
      render
    end

    it "displays a message" do
      expect(rendered).to have_text(t("group_members.index.no_members"))
    end
  end
end
