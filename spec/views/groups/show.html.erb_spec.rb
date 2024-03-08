require "rails_helper"

RSpec.describe "groups/show", type: :view do
  let(:current_user) { create :user }
  let(:forms) { [] }
  let(:group) { create :group, name: "My Group" }

  before do
    assign(:current_user, current_user)
    assign(:group, group)
    assign(:forms, forms)
    render
  end

  it "renders the group name in <h1>" do
    expect(rendered).to have_css "h1.govuk-heading-l", text: "My Group"
  end

  it "renders the status of the group" do
    expect(rendered).to have_css ".govuk-caption-l", text: t("groups.status_caption.trial")
  end

  it "has a link to the change group name page" do
    expect(rendered).to have_link "Change the name of this group", href: edit_group_path(group)
  end

  context "when the group has no forms" do
    let(:forms) { [] }

    it "does not have a table of forms" do
      expect(rendered).not_to have_table
    end
  end

  context "when the group has one of more forms" do
    let(:forms) do
      [
        build(:form, id: 1, name: "Form 1", has_draft_version: true, has_live_version: false),
        build(:form, id: 2, name: "Form 2", has_draft_version: false, has_live_version: true),
        build(:form, id: 3, name: "Form 3", has_draft_version: true, has_live_version: true),
      ]
    end

    it "renders a table listing the forms" do
      expect(rendered).to have_table "Forms in ‘My Group’"
      expect(rendered).to have_css "tbody .govuk-table__row", count: 3
    end

    it "renders a link for each form" do
      expect(rendered).to have_link("Form 1", href: form_path(1))
      expect(rendered).to have_link("Form 2", href: live_form_path(2))
      expect(rendered).to have_link("Form 3", href: live_form_path(3))
    end

    it "renders a status tag for each form" do
      page = Capybara.string(rendered.html)
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
        [{ text: "Draft", colour: "yellow" }],
        [{ text: "Live", colour: "turquoise" }],
        [{ text: "Draft", colour: "yellow" }, { text: "Live", colour: "turquoise" }],
      ]
    end
  end

  context "when the group is a trial group" do
    let(:group) { create :group, :trial, name: "trial group" }

    it "renders the status of the group" do
      expect(rendered).to have_css ".govuk-caption-l", text: t("groups.status_caption.trial")
    end

    it "shows a notification banner" do
      expect(rendered).to have_css ".govuk-notification-banner"
    end
  end

  context "when the group is an active group" do
    let(:group) { create :group, :active, name: "Active group" }

    it "renders the status of the group" do
      expect(rendered).to have_css ".govuk-caption-l", text: t("groups.status_caption.active")
    end

    it "does not show a notification banner" do
      expect(rendered).not_to have_css ".govuk-notification-banner"
    end
  end
end
