require "rails_helper"

describe "live/show_pages.html.erb" do
  let(:form) { build :form, :live, id: 1 }

  before do
    allow(view).to receive(:live_form_path).and_return("/live-form-path")
    render(template: "live/show_pages", locals: { form: })
  end

  it "form name is in the page title" do
    expect(view.content_for(:title)).to have_content(form.name)
  end

  it "back link is set to form_path" do
    expect(rendered).to have_link("Back to your form", href: "/live-form-path")
  end

  it "has correct page heading" do
    expect(rendered).to have_css("h1", text: "#{form.name} - Your questions", exact_text: true, normalize_ws: true)
  end

  it "rendered live tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--blue", text: "LIVE")
  end
end
