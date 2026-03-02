require "rails_helper"

describe "forms/archived/show_pages.html.erb" do
  let(:form_metadata) { create :form, :archived }
  let(:form_document) { FormDocument::Content.from_form_document(form_metadata.archived_form_document) }
  let(:welsh_form_document) { nil }

  before do
    render(template: "forms/archived/show_pages", locals: { form_document:, welsh_form_document: })
  end

  it "renders the made_live_form_pages partial" do
    expect(rendered).to render_template(partial: "forms/_made_live_form_pages")
  end

  it "back link is set to path to show an archived form" do
    expect(rendered).to have_link("Back to your form", href: "/forms/#{form_document.id}/archived")
  end

  it "rendered archived tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--orange", text: "Archived")
  end
end
