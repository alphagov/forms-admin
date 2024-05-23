require "rails_helper"

RSpec.describe "groups/show", type: :view do
  let(:current_user) { create :user, :org_has_signed_mou }
  let(:forms) { [] }
  let(:group) { create :group, name: "My Group" }
  let(:upgrade?) { false }
  let(:edit?) { true }
  let(:request_upgrade?) { false }
  let(:review_upgrade?) { false }

  before do
    assign(:current_user, current_user)
    assign(:group, group)
    assign(:forms, forms)

    without_partial_double_verification do
      double = instance_double(GroupPolicy,
                               upgrade?: upgrade?,
                               edit?: edit?,
                               request_upgrade?: request_upgrade?,
                               review_upgrade?: review_upgrade?)
      allow(view).to receive(:policy).and_return(double)
    end

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

  it "has a link to the edit members page" do
    expect(rendered).to have_link "Edit members of this group", href: group_members_path(group)
  end

  context "when the user does not have permission to edit the group" do
    let(:edit?) { false }

    it "does not have a link to the change group name page" do
      expect(rendered).not_to have_link "Change the name of this group", href: edit_group_path(group)
    end

    it "has a link to the review members page" do
      expect(rendered).to have_link "Review members of this group", href: group_members_path(group)
    end
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
        build(:form, id: 1, name: "Form 1"),
        build(:form, :live, id: 2, name: "Form 2"),
        build(:form, :live_with_draft, id: 3, name: "Form 3"),
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

    it "has the trial group heading in the notification banner" do
      expect(rendered).to have_css "h3", text: "This is a ‘trial’ group"
    end

    context "when the user has permission to upgrade the group" do
      let(:upgrade?) { true }
      let(:request_upgrade?) { true }

      it "shows content for an organisation admin" do
        expect(rendered).to have_text "Forms in this group cannot be made live unless the group is upgraded to an ‘active’ group."
      end

      it "shows a link to upgrade the group" do
        expect(rendered).to have_link("Upgrade this group", href: upgrade_group_path(group))
      end

      it "has the trial group heading in the notification banner" do
        expect(rendered).to have_css "h3", text: "This is a ‘trial’ group"
      end
    end
  end

  context "and the user has permission to request an upgrade" do
    let(:request_upgrade?) { true }

    it "shows content for a group admin" do
      expect(rendered).to have_text "You can create forms in this group and test them, but you cannot make them live."
    end

    it "shows a link to request an upgrade" do
      expect(rendered).to have_link("Find out how to upgrade this group so you can make forms live", href: request_upgrade_group_path(group))
    end

    it "has the trial group heading in the notification banner" do
      expect(rendered).to have_css "h3", text: "This is a ‘trial’ group"
    end

    context "and the org has not signed an MOU" do
      let(:current_user) { create :user }

      it "tells user to contact support to make forms live" do
        expect(rendered).to have_text("Speak to your organisation’s GOV.UK publishing team or contact the GOV.UK Forms team to find out how to make live forms.")
      end
    end
  end

  context "and the user has no permissions relating to upgrading groups" do
    it "shows content for an editor" do
      expect(rendered).to have_text "You can create a form, preview and test it."
    end
  end

  context "when the group has an upgrade requested" do
    let(:group) { create :group, :upgrade_requested }

    it "have the caption trial group" do
      expect(rendered).to have_css ".govuk-caption-l", text: "Trial group"
    end

    it "shows a notification banner" do
      expect(rendered).to have_css ".govuk-notification-banner"
    end

    it "has the trial group heading in the notification banner" do
      expect(rendered).to have_css "h3", text: "This is a ‘trial’ group"
    end

    context "when the user has permission to review upgrade requests" do
      let(:review_upgrade?) { true }
      let(:upgrade?) { true }
      let(:request_upgrade?) { true }
      let(:upgrade_requester) { create :user }
      let(:group) { create :group, status: :upgrade_requested, upgrade_requester: }

      it "has the heading in the notification banner for reviewing an upgrade request" do
        expect(rendered).to have_css "h3", text: "A group admin has asked to upgrade this group"
      end

      it "has the content in the notification banner for reviewing an upgrade request" do
        expect(rendered).to have_text "#{upgrade_requester.name} has asked to upgrade this group so they can make forms live."
      end

      it "shows a link to review the upgrade" do
        expect(rendered).to have_link("Accept or reject this upgrade request", href: review_upgrade_group_path(group))
      end
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

  it "has a start button to create a new form" do
    render
    expect(rendered).to have_css ".govuk-button--start", text: "Create a form" do |start_button|
      expect(start_button).to match_selector :link, href: new_group_form_path(group)
    end
  end
end
