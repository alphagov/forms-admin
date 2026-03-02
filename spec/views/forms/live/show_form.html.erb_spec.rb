require "rails_helper"

describe "forms/live/show_form.html.erb" do
  let(:form_metadata) { create :form, :live }
  let(:form_document) { FormDocument::Content.from_form_document(form_metadata.live_form_document) }

  before do
    render(template: "forms/live/show_form", locals: { form_document:, form_metadata: })
  end

  it "renders the live tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--turquoise", text: "Live")
  end

  it "contains a link to preview the live form" do
    expect(rendered).to have_link(t("home.preview"), href: "runner-host/preview-live/#{form_document.id}/#{form_document.form_slug}", visible: :all)
  end

  it "contains the form URL" do
    expect(rendered).to have_css("h3", text: "Form URL")
    expect(rendered).to have_text(link_to_runner(Settings.forms_runner.url, form_document.id, form_document.form_slug, mode: :live))
  end

  it "contains a link to view questions" do
    expect(rendered).to have_link("#{form_document.steps.count} questions", href: "/forms/#{form_document.id}/live/pages")
  end

  context "when the form has a Welsh translation" do
    let(:form_metadata) { create :form, :live, :with_welsh_translation }

    it "includes a link to preview the English version" do
      expect(rendered).to have_link("English", href: "runner-host/preview-live/#{form_document.id}/#{form_document.form_slug}", visible: :all)
    end

    it "includes a link to preview the Welsh version" do
      expect(rendered).to have_link("Preview this form in Welsh", href: "runner-host/preview-live/#{form_document.id}/#{form_document.form_slug}.cy", visible: :all)
    end

    it "contains the English form URL" do
      expect(rendered).to have_css("h3", text: "English form URL")
      expect(rendered).to have_text(link_to_runner(Settings.forms_runner.url, form_document.id, form_document.form_slug, mode: :live))
    end

    it "contains the Welsh form URL" do
      expect(rendered).to have_css("h3", text: "Welsh form URL")
      expect(rendered).to have_text(link_to_runner(Settings.forms_runner.url, form_document.id, form_document.form_slug, mode: :live, locale: :cy))
    end
  end
end
