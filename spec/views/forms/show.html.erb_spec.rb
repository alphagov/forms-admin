require "rails_helper"

describe "forms/show.html.erb" do
  let(:user) { build :user, role: :editor }
  let(:form) { OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "draft", pages:) }
  let(:pages) { [{ id: 183, question_text: "What is your address?", hint_text: "", answer_type: "address", next_page: nil }] }

  before do
    assign(:current_user, user)
    assign(:form, form)
    assign(:task_status_counts, { completed: 12, total: 20 })
    render template: "forms/show"
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: "Form 1")
    expect(rendered).to have_css("h1.govuk-heading-l", text: /Create a form/)
  end

  it "contains a link to preview the form" do
    expect(rendered).to have_link("Preview this form", href: "runner-host/preview-draft/1/form-1", visible: :all)
  end

  it "contains a link to delete the form" do
    expect(rendered).to have_link("Delete draft form", href: delete_form_path(1))
  end

  it "contains a summary of completed tasks out of the total tasks" do
    expect(rendered).to have_selector(".app-task-list__summary", text: "You’ve completed 12 of 20 tasks.")
  end

  context "when form states is a draft" do
    let(:form) { OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "draft", pages: []) }

    it "rendered draft tag " do
      expect(rendered).to have_css(".govuk-tag.govuk-tag--purple", text: "DRAFT")
    end

    it "has a back link to the forms page" do
      expect(view.content_for(:back_link)).to have_link("Back to your forms", href: "/")
    end
  end

  context "when form states is a live" do
    let(:form) { OpenStruct.new(id: 2, name: "Form 2", form_slug: "form-2", status: "live", has_live_version: true, pages: []) }

    it "has a back link to the live form page" do
      expect(view.content_for(:back_link)).to have_link("Back", href: "/forms/2/live")
    end

    it "rendered draft tag" do
      expect(rendered).to have_css(".govuk-tag.govuk-tag--purple", text: "DRAFT")
    end

    it "does not contain a link to delete the form" do
      expect(rendered).not_to have_link("Delete draft form", href: delete_form_path(2))
    end
  end

  context "and a user has the trial role" do
    let(:user) { build :user, :with_trial_role }

    it "displays a banner informing the user they have a trial account" do
      banner = Capybara.string(rendered).find(".govuk-notification-banner__content")

      expect(rendered).to have_selector(".govuk-notification-banner__content")
      expect(banner).to have_text(I18n.t("trial_role_warning.heading"))
      expect(Capybara.string(banner).text(normalize_ws: true)).to have_text(Capybara.string(I18n.t("trial_role_warning.content_html")).text(normalize_ws: true))
    end
  end

  context "and a user does not have the trial role" do
    let(:user) { build :user, role: :editor }

    it "does not display a banner" do
      expect(rendered).not_to have_selector(".govuk-notification-banner__content")
    end
  end
end
