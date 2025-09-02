require "rails_helper"

describe "archived/show_form.html.erb" do
  let(:form_metadata) { create :form, :archived }
  let(:form_document) { FormDocument::Content.from_form_document(form_metadata.archived_form_document) }

  before do
    render(template: "forms/archived/show_form", locals: { form_document:, form_metadata: })
  end

  it "renders the archived tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--orange", text: "Archived")
  end

  it "contains a link to preview the archived form" do
    expect(rendered).to have_link(t("home.preview"), href: "runner-host/preview-archived/#{form_document.id}/#{form_document.form_slug}", visible: :all)
  end

  it "contains the title 'Previous form URL'" do
    expect(rendered).to have_css("h3", text: "Previous form URL")
  end

  it "contains a link to view questions" do
    expect(rendered).to have_link("#{form_document.steps.count} questions", href: "/forms/#{form_document.id}/archived/pages")
  end

  it "contains a link to make the form live again" do
    expect(rendered).to have_link("Make this form live", href: "/forms/#{form_document.id}/unarchive")
  end
end
