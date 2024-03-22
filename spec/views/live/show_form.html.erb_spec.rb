require "rails_helper"

describe "live/show_form.html.erb" do
  let(:form_metadata) { OpenStruct.new(has_draft_version: false) }
  let(:form) { build(:form, :live, id: 1) }

  before do
    render(template: "forms/live/show_form", locals: { form:, form_metadata: })
  end

  it "renders the live tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--turquoise", text: "Live")
  end

  it "contains a link to preview the live form" do
    expect(rendered).to have_link(t("home.preview"), href: "runner-host/preview-live/#{form.id}/#{form.form_slug}", visible: :all)
  end

  it "contains the title 'Form URL'" do
    expect(rendered).to have_css("h2", text: "Form URL")
  end

  it "contains a link to view questions" do
    expect(rendered).to have_link("#{form.pages.count} questions", href: "/forms/#{form.id}/live/pages")
  end
end
