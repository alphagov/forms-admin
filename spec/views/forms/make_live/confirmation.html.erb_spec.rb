require "rails_helper"

describe "forms/make_live/confirmation.html.erb" do
  before do
    without_partial_double_verification do
      allow(view).to receive(:current_form).and_return(OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1"))
    end
    assign(:confirmation_page_title, "Your form is live")
    render template: "forms/make_live/confirmation"
  end

  it "contains a confirmation panel with a title" do
    expect(rendered).to have_css(".govuk-panel--confirmation h1", text: /Your form is live/)
  end

  it "contains the URL of the live form" do
    expect(rendered).to have_text("runner-host/form/1/form-1")
  end

  it "contains a link to the live form details" do
    expect(rendered).to have_link("Continue to form details", href: live_form_path(1))
  end
end
