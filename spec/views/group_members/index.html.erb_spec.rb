require "rails_helper"

describe "group_members/index", type: :view do
  let(:organisation) { build(:organisation, slug: "Department for testing group members") }
  let(:current_user) { create(:user, organisation:) }
  let(:user1) { build(:user, organisation:) }
  let(:user2) { build(:user, organisation:) }
  let(:memberships) { [create(:membership, user: user1, role: :editor, group:), create(:membership, user: user2, role: :group_admin, group:)] }
  let(:group) { create(:group, name: "Group 1", organisation:) }
  let(:can_add_editor) { true }
  let(:can_add_group_member) { false }
  let(:show_actions) { true }

  context "when there are members of a group" do
    before do
      memberships

      assign(:current_user, current_user)
      assign(:group, group)

      allow(Pundit).to receive(:policy).with(current_user, Membership).and_return(instance_double(MembershipPolicy, update?: true, destroy?: true))

      without_partial_double_verification do
        allow(view).to receive(:policy).and_return(OpenStruct.new(add_editor?: can_add_editor, add_group_admin?: can_add_group_member))
      end

      render locals: { show_actions: }
    end

    it "displays the group name" do
      expect(rendered).to have_selector("h1", text: group.name)
    end

    it "displays the page title" do
      expect(rendered).to have_selector("h1", text: t("group_members.index.title"))
    end

    it "has a back link to the group page" do
      expect(view.content_for(:back_link)).to have_link("Back to Group 1", href: group_path(group))
    end

    it "displays a table of group memberships" do
      group.memberships.each do |membership|
        expect(rendered).to have_selector("table td", text: membership.user.name)
        expect(rendered).to have_selector("table td", text: membership.user.email)
        expect(rendered).to have_selector("table td", text: t("group_members.index.roles.#{membership.role}.name"))
        expect(rendered).to have_selector("table th", text: t("group_members.index.table_headings.actions"))
        expect(rendered).to have_button(t("group_members.index.remove_member"), count: 2)
        expect(rendered).to have_button(t("group_members.index.make_editor"), count: 1)
        expect(rendered).to have_button(t("group_members.index.make_group_admin"), count: 1)
      end
    end

    it "has an add member link" do
      expect(rendered).to have_link(t("group_members.index.add_editor"), href: new_group_member_path(group))
    end

    context "when show_actions is false" do
      let(:show_actions) { false }

      it "does not display actions if show_actions is false" do
        expect(rendered).not_to have_selector("table th", text: t("group_members.index.table_headings.actions"))
        expect(rendered).not_to have_button(t("group_members.index.remove_member"))
        expect(rendered).not_to have_button(t("group_members.index.make_editor"))
        expect(rendered).not_to have_button(t("group_members.index.make_group_admin"))
      end
    end

    context "when there are no members of a group" do
      let(:memberships) { [] }

      it "displays a message" do
        expect(rendered).to have_text(t("group_members.index.no_members"))
      end
    end

    context "when the current user cannot add an editor" do
      let(:can_add_editor) { false }

      it "does not display the add member link" do
        expect(rendered).not_to have_link(href: new_group_member_path(group))
      end
    end

    context "when the current_user can add a group_admin" do
      let(:can_add_editor) { true }
      let(:can_add_group_member) { true }

      it "displays the link to add group_admin or editor" do
        expect(rendered).to have_link(t("group_members.index.add_member"), href: new_group_member_path(group))
      end
    end
  end
end
