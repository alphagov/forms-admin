require "rails_helper"

describe "archived/show_form.html.erb" do
  let(:form_metadata) { OpenStruct.new(has_draft_version: false) }
  let(:form) { build(:form, :archived, id: 1) }

  before do
    render(template: "forms/archived/show_form", locals: { form:, form_metadata: })
  end

  it "renders the archived tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--orange", text: "Archived")
  end

  it "contains a link to preview the archived form" do
    expect(rendered).to have_link(t("home.preview"), href: "runner-host/preview-archived/#{form.id}/#{form.form_slug}", visible: :all)
  end

  it "contains the title 'Previous form URL'" do
    expect(rendered).to have_css("h3", text: "Previous form URL")
  end

  it "contains a link to view questions" do
    expect(rendered).to have_link("#{form.pages.count} questions", href: "/forms/#{form.id}/archived/pages")
  end
end
