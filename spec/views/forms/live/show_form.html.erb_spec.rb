require "rails_helper"

describe "forms/live/show_form.html.erb" do
  let(:form_metadata) { create :form, :live }
  let(:form_document) { FormDocument::Content.new(form_metadata.live_form_document.content) }

  before do
    render(template: "forms/live/show_form", locals: { form_document:, form_metadata: })
  end

  it "renders the live tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--turquoise", text: "Live")
  end

  it "contains a link to preview the live form" do
    expect(rendered).to have_link(t("home.preview"), href: "runner-host/preview-live/#{form_document.id}/#{form_document.form_slug}", visible: :all)
  end

  it "contains the title 'Form URL'" do
    expect(rendered).to have_css("h2", text: "Form URL")
  end

  it "contains a link to view questions" do
    expect(rendered).to have_link("#{form_document.steps.count} questions", href: "/forms/#{form_document.id}/live/pages")
  end
end
