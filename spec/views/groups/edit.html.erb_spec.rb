require "rails_helper"

RSpec.describe "groups/edit", type: :view do
  let(:group) do
    create :group, name: "Name"
  end

  before do
    assign(:group, group)
    render
  end

  it "contains the page heading" do
    expect(rendered).to have_css("h1", text: I18n.t("groups.edit.title"))
  end

  it "renders the edit group form" do
    assert_select "form[action=?][method=?]", group_path(group), "post" do
      assert_select "input[name=?]", "group[name]"
    end
  end

  it "includes a form field for entering the group name" do
    expect(rendered).to have_field(I18n.t("groups.edit.title"))
  end

  it "includes the caption" do
    expect(rendered).to have_css(".govuk-caption-l", text: group.name)
  end
end
