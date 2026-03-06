require "rails_helper"

describe "mou_signatures/new.html.erb" do
  before do
    assign :agreement_type, agreement_type
    assign :mou_signature, MouSignature.new
    assign :create_path, create_path
    render template: "mou_signatures/new"
  end

  context "when the agreement_type is 'crown'" do
    let(:agreement_type) { :crown }
    let(:create_path) { mou_signature_path }

    it "has the correct page title" do
      expect(view.content_for(:title)).to have_content(I18n.t("page_titles.mou_signature_new"))
    end

    it "has the correct page heading" do
      expect(rendered).to have_css("h1", text: I18n.t("page_titles.mou_signature_new"))
    end

    it "renders the partial for the crown MOU" do
      expect(view).to render_template(partial: "_mou_version_current")
    end

    it "submits to the correct path" do
      expect(rendered).to have_css("form[action='#{mou_signature_path}']")
    end
  end

  context "when the agreement_type is 'non_crown'" do
    let(:agreement_type) { :non_crown }
    let(:create_path) { non_crown_agreement_signature_path }

    it "has the correct page title" do
      expect(view.content_for(:title)).to have_content(I18n.t("page_titles.non_crown_agreement_new"))
    end

    it "has the correct page heading" do
      expect(rendered).to have_css("h1", text: I18n.t("page_titles.non_crown_agreement_new"))
    end

    it "renders the partial for the non-crown agreement" do
      expect(view).to render_template(partial: "_non_crown_agreement_version_current")
    end

    it "submits to the correct path" do
      expect(rendered).to have_css("form[action='#{non_crown_agreement_signature_path}']")
    end
  end
end
