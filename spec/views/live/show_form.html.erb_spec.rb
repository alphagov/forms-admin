require "rails_helper"

describe "live/show_form.html.erb" do
  let(:declaration) { Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 4) }
  let(:what_happens_next) { Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 4) }
  let(:form) { build(:form, :live, id: 2, declaration_text: declaration, what_happens_next_text: what_happens_next) }

  around do |example|
    ClimateControl.modify RUNNER_BASE: "runner-host" do
      example.run
    end
  end

  before do
    allow(view).to receive(:form_pages_path).and_return("/form-pages-path")

    # assign(:form, form)
    render(template: "live/show_form", layout: "layouts/application", locals: { form: })
  end

  it "has the correct title" do
    expect(rendered).to have_title "#{form.name} – GOV.UK Forms"
  end

  it "back link is set to root" do
    expect(rendered).to have_link("Back to your forms", href: "/")
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: form.name)
  end

  it "rendered live tag" do
    expect(rendered).to have_css(".govuk-tag.govuk-tag--blue", text: "LIVE")
  end

  it "contains a link to preview the form" do
    expect(rendered).to have_link("Preview this form in a new tab", href: "runner-host/preview-form/2/#{form.form_slug}", visible: :all)
  end

  it "contains a link to the form in the runner" do
    expect(rendered).to have_content("runner-host/form/2/#{form.form_slug}")
  end

  it "contains a link to edit questions" do
    expect(rendered).to have_link("#{form.pages.count} questions", href: "/form-pages-path")
  end

  context "with only a single question" do
    let(:form) { build(:form, :live, id: 2, pages_count: 1) }

    it "contains a link to edit questions with correct pluralization" do
      expect(rendered).to have_link("1 question", href: "/form-pages-path")
    end
  end

  it "contains declaration" do
    expect(rendered).to have_css("h2", text: "Declaration")
    expect(rendered).to have_content(form.declaration_text)
  end

  context "with no declaration set" do
    let(:declaration) { nil }

    it "does not include declaration" do
      expect(rendered).not_to have_css("h2", text: "Declaration")
    end
  end

  it "contains what happens next text" do
    expect(rendered).to have_content(form.what_happens_next_text)
  end

  it "contains the submission email" do
    expect(rendered).to have_content(form.submission_email)
  end

  it "contains link to privacy policy " do
    expect(rendered).to have_link(form.privacy_policy_url, href: form.privacy_policy_url)
  end

  context "with a support email address" do
    let(:form) { build(:form, :live, id: 2, support_email: "support@example.gov.uk") }

    it "shows the support email address" do
      expect(rendered).to have_css("h3", text: "Email")
      expect(rendered).to have_content("support@example.gov.uk")
    end
  end

  context "with a support phone" do
    let(:form) { build(:form, :live, id: 2, support_phone: "phone details") }

    it "shows the support email address" do
      expect(rendered).to have_css("h3", text: "Phone")
      expect(rendered).to have_content("phone details")
    end
  end

  context "with a support online" do
    let(:form) { build(:form, :live, id: 2, support_url_text: "website", support_url: "www.example.gov.uk") }

    it "shows the support contact online" do
      expect(rendered).to have_css("h3", text: "Support contact online")
      expect(rendered).to have_link(form.support_url_text, href: form.support_url)
    end
  end

  context "with no support information set" do
    let(:form) { build(:form, :live, id: 2, support_email: nil, support_phone: nil, support_url_text: nil, support_url: nil) }

    it "does not include support details if they are not set" do
      expect(rendered).not_to have_css("h3", text: "Email")
      expect(rendered).not_to have_css("h3", text: "Phone")
      expect(rendered).not_to have_css("h3", text: "Support contact online")
    end
  end

  xit "contains a link to edit the form" do
    expect(rendered).to have_link("Edit this form", href: form_path(form.id, edit: true))
  end
end
