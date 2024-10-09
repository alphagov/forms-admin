require "rails_helper"

describe "reports/index.html.erb" do
  before do
    render template: "reports/index"
  end

  describe "page title" do
    it "matches the heading" do
      expect(view.content_for(:title)).to eq "Reports"
    end
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: "Reports")
  end

  it "includes a link to the features report" do
    expect(rendered).to have_link("Feature and answer type usage in live forms", href: report_features_path)
  end
end
