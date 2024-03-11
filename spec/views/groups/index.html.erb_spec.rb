require "rails_helper"

RSpec.describe "groups/index", type: :view do
  let(:trial_groups) { create_list :group, 2 }
  let(:active_groups) { create_list :group, 2, status: :active }

  before do
    assign(:trial_groups, trial_groups)
    assign(:active_groups, active_groups)

    render
  end

  it "renders a list of groups" do
    trial_groups.each do |group|
      expect(rendered).to have_link(group.name, href: group_path(group))
    end

    active_groups.each do |group|
      expect(rendered).to have_link(group.name, href: group_path(group))
    end
  end

  it "shows a create group button" do
    expect(rendered).to have_link("Create a group", href: new_group_path)
  end
end
