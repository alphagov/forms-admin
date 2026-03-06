require "rails_helper"

describe "mou_signatures/show.html.erb" do
  let(:date) { "12 October 2023" }

  before do
    assign :agreement_type, agreement_type
    assign :mou_signature, build(:mou_signature, created_at: Time.zone.parse(date))
    render template: "mou_signatures/show"
  end

  context "when the agreement_type is 'crown'" do
    let(:agreement_type) { :crown }

    it "has the correct page title" do
      expect(view.content_for(:title)).to have_content(I18n.t("page_titles.mou_signature_new"))
    end

    it "has the correct page heading" do
      expect(rendered).to have_css("h1", text: I18n.t("page_titles.mou_signature_new"))
    end

    it "has the correct banner title" do
      expect(rendered).to have_css(".govuk-notification-banner", text: I18n.t("mou_signatures.show.crown.banner.title"))
    end

    it "has the correct banner content" do
      expect(rendered).to have_css(".govuk-notification-banner__heading", text: I18n.t("mou_signatures.show.crown.banner.heading", date: date))
    end

    it "renders the partial for the crown MOU" do
      expect(view).to render_template(partial: "_mou_version_current")
    end
  end

  context "when the agreement_type is 'non_crown'" do
    let(:agreement_type) { :non_crown }

    it "has the correct page title" do
      expect(view.content_for(:title)).to have_content(I18n.t("page_titles.non_crown_agreement_new"))
    end

    it "has the correct page heading" do
      expect(rendered).to have_css("h1", text: I18n.t("page_titles.non_crown_agreement_new"))
    end

    it "has the correct banner title" do
      expect(rendered).to have_css(".govuk-notification-banner", text: I18n.t("mou_signatures.show.non_crown.banner.title"))
    end

    it "has the correct banner content" do
      expect(rendered).to have_css(".govuk-notification-banner__heading", text: I18n.t("mou_signatures.show.non_crown.banner.heading", date: date))
    end

    it "renders the partial for the non-crown agreement" do
      expect(view).to render_template(partial: "_non_crown_agreement_version_current")
    end
  end
end
