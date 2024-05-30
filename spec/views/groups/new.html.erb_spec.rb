require "rails_helper"

RSpec.describe "groups/new", type: :view do
  before do
    assign(:group, Group.new(
                     name: "MyString",
                   ))
    render
  end

  it "contains the page heading" do
    expect(rendered).to have_css("h1", text: I18n.t("groups.new.title"))
  end

  it "renders the new group form" do
    assert_select "form[action=?][method=?]", groups_path, "post" do
      assert_select "input[name=?]", "group[name]"
    end
  end

  it "includes a form field for entering the group name" do
    expect(rendered).to have_field(I18n.t("helpers.label.group.name"))
  end

  it "includes the body text" do
    expect(rendered).to include(I18n.t("groups.new.body_html"))
  end
end
