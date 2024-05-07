require "rails_helper"

describe "groups/upgrade_requested.html.erb" do
  let(:group) { create(:group) }

  before do
    assign(:group, group)
    render
  end

  it "has a back link" do
    expect(view.content_for(:back_link)).to have_link("Back", href: group_path(group))
  end

  it "has a link to go back to the group" do
    expect(rendered).to have_link("Back to #{group.name}", href: group_path(group))
  end
end
