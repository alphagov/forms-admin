require "rails_helper"

describe "forms/_made_live_form.html.erb" do
  let(:declaration) { Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 4) }
  let(:metrics_data) { { weekly_submissions: 125, weekly_starts: 256 } }
  let(:what_happens_next) { Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 4) }
  let(:form_metadata) { OpenStruct.new(has_draft_version: false) }
  let(:form) { build(:form, :live, id: 2, declaration_text: declaration, what_happens_next_markdown: what_happens_next, live_at: 1.week.ago) }
  let(:group) { create(:group, name: "Group 1") }
  let(:status) { :live }
  let(:preview_mode) { :preview_live }
  let(:questions_path) { Faker::Internet.url }

  before do
    allow(form).to receive(:metrics_data).and_return(metrics_data)

    if group.present?
      GroupForm.create!(form_id: form.id, group_id: group.id)
    end

    render(partial: "forms/made_live_form", locals: {
      form_metadata:,
      form:,
      status:,
      preview_mode:,
      questions_path:,
    })
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content(form.name.to_s)
  end

  it "back link is set to group page" do
    expect(view.content_for(:back_link)).to have_link("Back to Group 1", href: group_path(group))
  end

  it "contains page heading" do
    expect(rendered).to have_css("h1.govuk-heading-xl", text: form.name)
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
        expect(rendered).to have_link(t("home.preview"), href: "runner-host/preview-live/2/#{form.form_slug}", visible: :all)
      end
    end

    context "when the form is archived" do
      let(:preview_mode) { :preview_archived }

      it "contains a link to preview the archived form" do
        expect(rendered).to have_link(t("home.preview"), href: "runner-host/preview-archived/2/#{form.form_slug}", visible: :all)
      end
    end
  end

  describe "the link to the live form" do
    context "when the form is live" do
      it "contains the title 'Form URL'" do
        expect(rendered).to have_css("h2", text: "Form URL")
      end

      it "contains a link to the form in the runner" do
        expect(rendered).to have_content("runner-host/form/2/#{form.form_slug}")
      end
    end

    context "when the form is archived" do
      let(:status) { :archived }

      it "contains the title 'Previous form URL'" do
        expect(rendered).to have_css("h3", text: "Previous form URL")
      end

      it "contains a link to the form in the runner" do
        expect(rendered).to have_content("runner-host/form/2/#{form.form_slug}")
      end
    end
  end

  it "contains a link to view questions" do
    expect(rendered).to have_link("#{form.pages.count} questions", href: questions_path)
  end

  context "with only a single question" do
    let(:form) { build(:form, :live, id: 2, pages_count: 1) }

    it "contains a link to view questions with correct pluralization" do
      expect(rendered).to have_link("1 question", href: questions_path)
    end
  end

  it "contains declaration" do
    expect(rendered).to have_css("h3", text: "Declaration")
    expect(rendered).to have_content(form.declaration_text)
  end

  context "with no declaration set" do
    let(:declaration) { nil }

    it "does not include declaration" do
      expect(rendered).not_to have_css("h3", text: "Declaration")
    end
  end

  it "contains what happens next text" do
    expect(rendered).to have_content(form.what_happens_next_markdown)
  end

  it "contains the submission email" do
    expect(rendered).to have_content(form.submission_email)
  end

  it "contains link to privacy policy" do
    expect(rendered).to have_link(form.privacy_policy_url, href: form.privacy_policy_url)
  end

  context "with a support email address" do
    let(:form) { build(:form, :live, id: 2, support_email: "support@example.gov.uk") }

    it "shows the support email address" do
      expect(rendered).to have_css("h4", text: "Email")
      expect(rendered).to have_content("support@example.gov.uk")
    end
  end

  context "with a support phone" do
    let(:form) { build(:form, :live, id: 2, support_phone: "phone details") }

    it "shows the support email address" do
      expect(rendered).to have_css("h4", text: "Phone")
      expect(rendered).to have_content("phone details")
    end
  end

  context "with a support online" do
    let(:form) { build(:form, :live, id: 2, support_url_text: "website", support_url: "www.example.gov.uk") }

    it "shows the support contact online" do
      expect(rendered).to have_css("h4", text: "Support contact online")
      expect(rendered).to have_link(form.support_url_text, href: form.support_url)
    end
  end

  context "with no support information set" do
    let(:form) { build(:form, :live, id: 2, support_email: nil, support_phone: nil, support_url_text: nil, support_url: nil) }

    it "does not include support details if they are not set" do
      expect(rendered).not_to have_css("h4", text: "Email")
      expect(rendered).not_to have_css("h4", text: "Phone")
      expect(rendered).not_to have_css("h4", text: "Support contact online")
    end
  end

  it "contains a link to create a new draft" do
    expect(rendered).to have_link("Create a draft to edit", href: form_path(form.id))
  end

  context "when form has a draft version already" do
    let(:form_metadata) { OpenStruct.new(has_draft_version: true) }

    it "contains a link to edit the draft" do
      expect(rendered).to have_link("Edit the draft of this form", href: form_path(form.id))
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
    expect(rendered).to have_text("If you want to track metrics over a longer period you'll need to make a note of these on the same day each week.")
  end

  context "when form is not in a group" do
    let(:group) { nil }

    it "back link is set to root" do
      expect(view.content_for(:back_link)).to have_link("Back to your forms", href: "/")
    end
  end

  context "when the groups feature is not enabled", feature_groups: false do
    it "back link is set to root" do
      expect(view.content_for(:back_link)).to have_link("Back to your forms", href: "/")
    end
  end
end
