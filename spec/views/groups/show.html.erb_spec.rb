require "rails_helper"

RSpec.describe "groups/show", type: :view do
  let(:group) { create :group, name: "Name" }

  before do
    assign(:group, group)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
