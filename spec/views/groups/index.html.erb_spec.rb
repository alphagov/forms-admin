require "rails_helper"

RSpec.describe "groups/index", type: :view do
  let(:groups) { create_list :group, 2, name: "Name" }

  before do
    assign(:groups, groups)
  end

  it "renders a list of groups" do
    render
    cell_selector = ".govuk-summary-list__value"
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
  end
end
