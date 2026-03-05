require "rails_helper"

describe "mou_signatures/confirmation.html.erb" do
  before do
    assign :agreement_type, agreement_type
    assign :mou_signature, build(:mou_signature)
    render template: "mou_signatures/confirmation"
  end

  context "when the agreement_type is 'crown'" do
    let(:agreement_type) { :crown }

    it "has the correct page title" do
      expect(view.content_for(:title)).to have_content(I18n.t("page_titles.mou_signature_confirmation"))
    end

    it "has the correct page heading" do
      expect(rendered).to have_css("h1", text: I18n.t("page_titles.mou_signature_confirmation"))
    end

    it "has the correct body" do
      expect(rendered).to have_text("We’ll email you with any updates to the MOU that are made in the future.")
    end
  end

  context "when the agreement_type is 'non_crown'" do
    let(:agreement_type) { :non_crown }

    it "has the correct page title" do
      expect(view.content_for(:title)).to have_content(I18n.t("page_titles.non_crown_agreement_confirmation"))
    end

    it "has the correct page heading" do
      expect(rendered).to have_css("h1", text: I18n.t("page_titles.non_crown_agreement_confirmation"))
    end

    it "has the correct body" do
      expect(rendered).to have_text("We’ll email you with any updates to the agreement that are made in the future.")
    end
  end
end
