require "rails_helper"

describe "forms/live/show_pages.html.erb" do
  let(:form) { build :made_live_form, id: 1 }

  before do
    render(template: "forms/live/show_pages", locals: { form: })
  end

  it "form name is in the page title" do
    expect(view.content_for(:title)).to have_content(form.name)
  end

  it "back link is set to the path to show a live form" do
    expect(rendered).to have_link("Back to your form", href: "/forms/#{form.id}/live")
  end

  it "has correct page heading" do
    expect(rendered).to have_css("h1", text: "#{form.name} - Your questions", exact_text: true, normalize_ws: true)
  end

  it "rendered live tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--turquoise", text: "Live")
  end
end
