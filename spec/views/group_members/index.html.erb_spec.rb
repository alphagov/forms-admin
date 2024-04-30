require "rails_helper"

describe "group_members/index", type: :view do
  let(:organisation) { build(:organisation, slug: "Department for testing group members") }
  let(:group) { create(:group, name: "Group 1", organisation:) }
  let(:add_editor) { false }

  let(:rows) do
    [
      OpenStruct.new({ name: "user1", email: "user1@gov.uk", role: :editor, actions: [], membership: { id: 1 } }),
      OpenStruct.new({ name: "user2", email: "user2@gov.uk", role: :group_admin, actions: [:delete], membership: { id: 1 } }),
    ]
  end

  before do
    assign(:group, group)
    assign(:group_member_service, instance_double(GroupMemberService, rows:, show_actions?: true))

    allow(Pundit).to receive(:policy).and_return(instance_double(GroupPolicy, add_editor?: add_editor))

    render
  end

  context "when there are members of a group" do
    it "displays the group name" do
      expect(rendered).to have_selector("h1", text: group.name)
    end

    it "displays the page title" do
      expect(rendered).to have_selector("h1", text: t("group_members.index.title"))
    end

    it "displays a table of group memberships" do
      rows.each do |row|
        expect(rendered).to have_selector("td", text: row.name)
        expect(rendered).to have_selector("td", text: row.email)
        expect(rendered).to have_selector("td", text: t("group_members.index.roles.#{row.role}.name"))
      end

      expect(rendered).to have_button(t("group_members.index.remove_member"), count: 1)
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
    let(:rows) { [] }

    it "displays a message" do
      expect(rendered).to have_text(t("group_members.index.no_members"))
    end
  end
end
