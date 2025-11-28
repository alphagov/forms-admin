require "rails_helper"

describe "forms/_made_live_form.html.erb" do
  let(:declaration_text) { Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 4) }
  let(:past_week_metrics_data) { { weekly_submissions: 125, weekly_starts: 256 } }
  let(:what_happens_next_markdown) { Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 4) }
  let(:form_metadata) { create :form, :live, declaration_text:, what_happens_next_markdown:, submission_type:, submission_format: }
  let(:form_document) do
    form_document_content = FormDocument::Content.from_form_document(form_metadata.live_form_document)
    form_document_content.first_made_live_at = 1.week.ago
    form_document_content
  end
  let(:group) { create(:group, name: "Group 1") }
  let(:status) { :live }
  let(:preview_mode) { :preview_live }
  let(:questions_path) { Faker::Internet.url }
  let(:submission_type) { "email" }
  let(:submission_format) { [] }
  let(:cloudwatch_service) { instance_double(CloudWatchService, past_week_metrics_data:) }

  before do
    allow(CloudWatchService).to receive(:new).and_return(cloudwatch_service)

    if group.present?
      GroupForm.create!(form_id: form_document.id, group_id: group.id)
    end

    render(partial: "forms/made_live_form", locals: {
      form_metadata:,
      form_document:,
      status:,
      preview_mode:,
      questions_path:,
    })
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content(form_document.name.to_s)
  end

  it "back link is set to group page" do
    expect(view.content_for(:back_link)).to have_link("Back to Group 1", href: group_path(group))
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-xl", text: form_document.name)
  end

  describe "form status tag" do
    context "when the form is live" do
      it "renders the live tag" do
        expect(rendered).to have_css(".govuk-tag.govuk-tag--turquoise", text: "Live")
      end
    end

    context "when the form is archived" do
      let(:status) { :archived }

      it "renders the archived tag" do
        expect(rendered).to have_css(".govuk-tag.govuk-tag--orange", text: "Archived")
      end
    end
  end

  describe "the link to the preview form" do
    context "when the form is live" do
      it "contains a link to preview the form" do
        expect(rendered).to have_link(t("home.preview"), href: "runner-host/preview-live/#{form_document.id}/#{form_document.form_slug}", visible: :all)
      end
    end

    context "when the form is archived" do
      let(:preview_mode) { :preview_archived }

      it "contains a link to preview the archived form" do
        expect(rendered).to have_link(t("home.preview"), href: "runner-host/preview-archived/#{form_document.id}/#{form_document.form_slug}", visible: :all)
      end
    end
  end

  describe "the link to the live form" do
    context "when the form is live" do
      it "contains the title 'Form URL'" do
        expect(rendered).to have_css("h2", text: "Form URL")
      end

      it "contains a link to the form in the runner" do
        expect(rendered).to have_content("runner-host/form/#{form_document.id}/#{form_document.form_slug}")
      end
    end

    context "when the form is archived" do
      let(:status) { :archived }

      it "contains the title 'Previous form URL'" do
        expect(rendered).to have_css("h3", text: "Previous form URL")
      end

      it "contains a link to the form in the runner" do
        expect(rendered).to have_content("runner-host/form/#{form_document.id}/#{form_document.form_slug}")
      end
    end
  end

  it "contains a link to view questions" do
    expect(rendered).to have_link("#{form_document.steps.count} questions", href: questions_path)
  end

  context "with only a single question" do
    let(:form_metadata) { create :form, :live, pages_count: 1 }

    it "contains a link to view questions with correct pluralization" do
      expect(rendered).to have_link("1 question", href: questions_path)
    end
  end

  it "contains declaration" do
    expect(rendered).to have_css("h3", text: "Declaration")
    expect(rendered).to have_content(declaration_text)
  end

  context "with no declaration set" do
    let(:declaration_text) { nil }

    it "does not include declaration" do
      expect(rendered).not_to have_css("h3", text: "Declaration")
    end
  end

  it "contains what happens next text" do
    expect(rendered).to have_content(what_happens_next_markdown)
  end

  it "contains information about how you get completed forms" do
    expect(rendered).to have_css("h3", text: I18n.t("made_live_form.how_you_get_completed_forms"))
    expect(rendered).to have_xpath("//h3[text()='#{I18n.t('made_live_form.how_you_get_completed_forms')}']/following-sibling::h4", text: "Email")
    expect(rendered).to have_text(form_document.submission_email)
  end

  context "when the submission type is 'email'" do
    context "when CSV submission is enabled" do
      let(:submission_format) { %w[csv] }

      it "tells the user they have CSVs enabled" do
        expect(rendered).to have_css("h4", text: I18n.t("made_live_form.csv_and_json"))
        expect(rendered).to include(I18n.t("made_live_form.submission_format.email.email_csv_html"))
      end
    end

    context "when JSON submission is enabled" do
      let(:submission_format) { %w[json] }

      it "tells the user they have JSON submissions enabled" do
        expect(rendered).to have_css("h4", text: I18n.t("made_live_form.csv_and_json"))
        expect(rendered).to include(I18n.t("made_live_form.submission_format.email.email_json_html"))
      end
    end

    context "when both CSV and JSON submissions are enabled" do
      let(:submission_format) { %w[csv json] }

      it "tells the user they have CSV and JSON submissions enabled" do
        expect(rendered).to have_css("h4", text: I18n.t("made_live_form.csv_and_json"))
        expect(rendered).to include(I18n.t("made_live_form.submission_format.email.email_csv_json_html"))
      end
    end

    context "when CSV submission is not enabled" do
      let(:submission_format) { %w[] }

      it "tells the user they do not have CSVs enabled" do
        expect(rendered).to have_css("h4", text: I18n.t("made_live_form.csv_and_json"))
        expect(rendered).to include(I18n.t("made_live_form.submission_format.email.email_html"))
      end
    end
  end

  context "when the submission type is 's3'" do
    let(:submission_type) { "s3" }

    it "does not include the CSV and JSON section" do
      expect(rendered).not_to have_css("h4", text: I18n.t("made_live_form.csv_and_json"))
    end
  end

  it "contains link to privacy policy" do
    expect(rendered).to have_link(form_document.privacy_policy_url, href: form_document.privacy_policy_url)
  end

  context "with a support email address" do
    let(:form_metadata) { create :form, :live, support_email: "support@example.gov.uk" }

    it "shows the support email address" do
      expect(rendered).to have_xpath("//h3[text()='#{I18n.t('made_live_form.contact_details')}']/following-sibling::h4", text: "Email")
      expect(rendered).to have_content("support@example.gov.uk")
    end
  end

  context "with a support phone" do
    let(:form_metadata) { create :form, :live, support_phone: "phone details" }

    it "shows the support phone number" do
      expect(rendered).to have_css("h4", text: "Phone")
      expect(rendered).to have_content("phone details")
    end
  end

  context "with a support online" do
    let(:form_metadata) { create :form, :live, support_url_text: "website", support_url: "www.example.gov.uk" }

    it "shows the support contact online" do
      expect(rendered).to have_css("h4", text: "Support contact online")
      expect(rendered).to have_link(form_document.support_url_text, href: form_document.support_url)
    end
  end

  context "with no support information set" do
    let(:form_document) do
      form_document_content = FormDocument::Content.from_form_document(form_metadata.live_form_document)
      form_document_content.support_email = nil
      form_document_content.support_url_text = nil
      form_document_content.support_url = nil
      form_document_content.support_phone = nil
      form_document_content
    end

    it "does not include support details if they are not set" do
      expect(rendered).not_to have_xpath("//h3[text()='#{I18n.t('made_live_form.contact_details')}']/following-sibling::h4", text: "Email")
      expect(rendered).not_to have_css("h4", text: "Phone")
      expect(rendered).not_to have_css("h4", text: "Support contact online")
    end
  end

  it "contains a link to create a new draft" do
    expect(rendered).to have_link("Create a draft to edit", href: form_path(form_document.id))
  end

  context "when form has a draft version already" do
    let(:form_metadata) { create :form, :live_with_draft }

    it "contains a link to edit the draft" do
      expect(rendered).to have_link("Edit the draft of this form", href: form_path(form_document.id))
    end
  end

  describe "the archive this form button" do
    context "when the form is live" do
      it "contains a link to archive the form" do
        expect(rendered).to have_link("Archive this form")
      end
    end

    context "when the form is archived" do
      let(:status) { :archived }

      it "does not contain a link to archive the form" do
        expect(rendered).not_to have_link("Archive this form")
      end
    end
  end

  it "renders the metrics summary component" do
    expect(rendered).to have_text("If you want to track metrics over a longer period you’ll need to make a note of these on the same day each week.")
  end

  context "when form is not in a group" do
    let(:group) { nil }

    it "back link is set to root" do
      expect(view.content_for(:back_link)).to have_link("Back to your forms", href: "/")
    end
  end

  context "when the form has a payment link" do
    let(:payment_url) { "https://www.gov.uk/payments/your-payment-link" }
    let(:form_metadata) { create :form, :live, payment_url: }

    it "contains a link to the payment url" do
      expect(rendered).to have_css("h3", text: "GOV.UK Pay payment link")
      expect(rendered).to have_link(payment_url, href: payment_url)
    end
  end
end
