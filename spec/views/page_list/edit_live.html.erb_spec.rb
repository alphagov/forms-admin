require "rails_helper"

describe "page_list/edit_live.html.erb" do
  let(:form) { build :form, :live, id: 1 }

  before do
    assign(:form, form)
    assign(:pages, form.pages)

    allow(view).to receive(:form_path).and_return("/form-path")

    render(template: "page_list/edit_live", layout: "layouts/application")
  end

  it "form name is in the page title" do
    expect(rendered).to have_title(form.name.to_s)
  end

  it "back link is set to form_path" do
    expect(rendered).to have_link("Back to view your form", href: "/form-path")
  end

  it "has correct page heading" do
    expect(rendered).to have_css("h1", text: "#{form.name} - Your questions", exact_text: true, normalize_ws: true)
  end

  it "rendered live tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--blue", text: "LIVE")
  end
end
