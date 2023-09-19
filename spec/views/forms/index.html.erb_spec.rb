require "rails_helper"

describe "forms/index.html.erb" do
  let(:user) { build :user, role: :editor }
  let(:forms) { [] }

  before do
    assign(:current_user, user)
    assign(:forms, forms)
    render template: "forms/index"
  end

  describe "when there are no forms to display" do
    it "allows the user to create a new form" do
      expect(rendered).to have_link("Create a form", href: forms_new_path)
    end

    it "does not contain a a list of forms" do
      expect(rendered).not_to have_table
    end
  end

  describe "when there are one or more forms to display" do
    let(:forms) do
      [
        OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", has_draft_version: true, has_live_version: false),
        OpenStruct.new(id: 2, name: "Form 2", form_slug: "form-2", has_draft_version: false, has_live_version: true),
        OpenStruct.new(id: 3, name: "Form 3", form_slug: "form-3", has_draft_version: true, has_live_version: true),
      ]
    end

    it "allows the user to create a new form" do
      expect(rendered).to have_link("Create a form", href: forms_new_path)
    end

    it "does contain a table listing the users forms and their status" do
      expect(rendered).to have_css "tbody .govuk-table__row", count: 3
    end

    it "has a table caption with the name of the organisation that owns the forms" do
      expect(rendered).to have_css(".govuk-table__caption", text: "#{user.organisation.name} forms")
    end

    it "displays links for each form" do
      expect(rendered).to have_link("Form 1", href: form_path(1))
      expect(rendered).to have_link("Form 2", href: live_form_path(2))
      expect(rendered).to have_link("Form 3", href: live_form_path(3))
    end

    it "has status tags for each form" do
      page = Capybara.string(rendered)
      table_rows = page.find_all("tbody .govuk-table__row")
      status_tags = table_rows.map do |row|
        row.find_all(".govuk-tag").map do |status_tag|
          {
            text: status_tag.text,
            colour: status_tag[:class].delete_prefix("govuk-tag govuk-tag--").strip,
          }
        end
      end

      expect(status_tags).to eq [
        [{ text: "DRAFT", colour: "purple" }],
        [{ text: "LIVE", colour: "blue" }],
        [{ text: "DRAFT", colour: "purple" }, { text: "LIVE", colour: "blue" }],
      ]
    end

    context "with a user has no organisation" do
      let(:user) { build :user, :with_no_org, role: :editor }

      it "has a table caption without an organisation name" do
        expect(rendered).to have_css(".govuk-table__caption", text: "Your forms")
      end
    end

    context "with a user with a trial role" do
      let(:user) { build :user, :with_trial_role }

      it "has a table caption without an organisation name" do
        expect(rendered).to have_css(".govuk-table__caption", text: "Your forms")
      end
    end

    context "when a form is live renders link to 'live' form readonly view" do
      let(:forms) { [OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1", status: "draft", has_live_version: false), OpenStruct.new(id: 2, name: "Form 2", form_slug: "form-2", status: "live", has_live_version: true)] }

      it "allows the user to create a new form" do
        expect(rendered).to have_link("Create a form", href: forms_new_path)
      end

      it "does contain a table listing the users forms and their status" do
        expect(rendered).to have_css "tbody .govuk-table__row", count: 2
      end

      it "displays links for each form" do
        expect(rendered).to have_link("Form 1", href: form_path(1))
        expect(rendered).to have_link("Form 2", href: live_form_path(2))
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
end
