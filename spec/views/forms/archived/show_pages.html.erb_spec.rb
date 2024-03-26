require "rails_helper"

describe "forms/archived/show_pages.html.erb" do
  let(:form) { build :form, :archived, id: 1 }

  before do
    render(template: "forms/archived/show_pages", locals: { form: })
  end

  it "form name is in the page title" do
    expect(view.content_for(:title)).to have_content(form.name)
  end

  it "back link is set to path to show an archived form" do
    expect(rendered).to have_link("Back to your form", href: "/forms/#{form.id}/archived")
  end

  it "has correct page heading" do
    expect(rendered).to have_css("h1", text: "#{form.name} - Your questions", exact_text: true, normalize_ws: true)
  end

  it "rendered archived tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--orange", text: "Archived")
  end
end
