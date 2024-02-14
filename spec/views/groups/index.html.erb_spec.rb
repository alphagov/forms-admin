require "rails_helper"

RSpec.describe "groups/index", type: :view do
  before do
    assign(:groups, [
      Group.create!(
        name: "Name",
      ),
      Group.create!(
        name: "Name",
      ),
    ])
  end

  it "renders a list of groups" do
    render
    cell_selector = ".govuk-summary-list__value"
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
  end
end
