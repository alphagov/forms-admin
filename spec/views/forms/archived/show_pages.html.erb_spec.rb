require "rails_helper"

describe "forms/archived/show_pages.html.erb" do
  let(:form_metadata) { create :form, :archived }
  let(:form_document) { FormDocument::Content.from_form_document(form_metadata.archived_form_document) }

  before do
    render(template: "forms/archived/show_pages", locals: { form_document: })
  end

  it "form name is in the page title" do
    expect(view.content_for(:title)).to have_content(form_document.name)
  end

  it "back link is set to path to show an archived form" do
    expect(rendered).to have_link("Back to your form", href: "/forms/#{form_document.id}/archived")
  end

  it "has correct page heading" do
    expect(rendered).to have_css("h1", text: "#{form_document.name} - Your questions", exact_text: true, normalize_ws: true)
  end

  it "rendered archived tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--orange", text: "Archived")
  end
end
