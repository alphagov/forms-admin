require "rails_helper"

describe "groups/confirm_upgrade_request.html.erb" do
  let(:group) { create(:group) }

  before do
    assign(:group, group)
    render
  end

  it "has a back link to group page" do
    expect(view.content_for(:back_link)).to have_link("Back", href: group_path(group))
  end

  it "has a form that will POST to the correct URL" do
    expect(rendered).to have_css("form[action='#{request_upgrade_group_path(group)}'][method='post']")
  end

  it "renders the group name in the heading caption" do
    expect(rendered).to have_css(".govuk-caption-l", text: group.name)
  end
end
