require "rails_helper"

describe "forms/make_live/confirmation.html.erb" do
  around do |example|
    ClimateControl.modify RUNNER_BASE: "runner-host" do
      example.run
    end
  end

  before do
    assign(:form, OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1"))
    render template: "forms/make_live/confirmation"
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css(".govuk-caption-l:has(+ h1)", text: "Form 1")
    expect(rendered).to have_css("h1.govuk-heading-l", text: /Your form is live/)
  end

  it "contains the URL of the live form" do
    expect(rendered).to have_text("runner-host/form/1/form-1")
  end

  it "contains a link to the form details" do
    expect(rendered).to have_link("Continue to form details", href: form_path(1))
  end
end
