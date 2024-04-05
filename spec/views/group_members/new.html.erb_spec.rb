require "rails_helper"

RSpec.describe "group_members/new", type: :view do
  let(:organisation) { build(:organisation, slug: "Department for testing new group members") }
  let(:group) { create(:group, name: "Group 1", organisation:) }

  before do
    assign(:group, group)
    render
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
end
