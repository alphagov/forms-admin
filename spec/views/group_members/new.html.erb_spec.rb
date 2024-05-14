require "rails_helper"

RSpec.describe "group_members/new", type: :view do
  let(:organisation) { build(:organisation, slug: "Department for testing new group members") }
  let(:group) { create(:group, name: "Group 1", organisation:) }
  let(:group_member_input) { GroupMemberInput.new }
  let(:show_role_options) { false }

  before do
    assign(:group, group)
    assign(:group_member_input, group_member_input)
    render locals: { show_role_options: }
  end

  it "displays the group name" do
    expect(rendered).to have_selector("h1", text: group.name)
  end

  it "displays the page title" do
    expect(rendered).to have_selector("h1", text: t("group_members.new.title"))
  end

  it "has a back link to group members page" do
    expect(view.content_for(:back_link)).to have_link("Back", href: group_members_path(group))
  end

  context "when show_role_options is true" do
    let(:show_role_options) { true }

    it "shows radio buttons for role" do
      Membership.roles.each_key do |role|
        expect(rendered).to have_field("group_member_input[role]", with: role)
      end
    end

    it "displays the correct page title" do
      expect(rendered).to have_selector("h1", text: t("group_members.new.title_show_role_options"))
    end
  end
end
