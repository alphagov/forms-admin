require "rails_helper"

describe "forms/show_live.html.erb" do
  let(:form) { build(:form, :live, id: 2) }

  around do |example|
    ClimateControl.modify RUNNER_BASE: "runner-host" do
      example.run
    end
  end

  before do
    assign(:form, form)
    render template: "forms/show_live"
  end

  it "contains placeholder text" do
    expect(rendered).to have_content("placeholder")
  end
end
