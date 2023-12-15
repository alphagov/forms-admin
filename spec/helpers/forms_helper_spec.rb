require "rails_helper"

RSpec.describe FormsHelper, type: :helper do
  describe "#forms_table_caption" do
    context "when organisation_name is blank" do
      it 'returns the translated string "home.your_forms"' do
        expect(helper.forms_table_caption("")).to eq(I18n.t("home.your_forms"))
        expect(helper.forms_table_caption(nil)).to eq(I18n.t("home.your_forms"))
      end
    end

    context "when organisation_name is not blank" do
      it 'returns the translated string "home.form_table_caption" with the organisation_name' do
        organisation_name = "Example dept"
        caption = I18n.t("home.form_table_caption", organisation_name:)
        expect(helper.forms_table_caption(organisation_name)).to eq(caption)
      end
    end
  end

  describe "#user_organisation_name" do
    let(:trial_user) { build(:user, :with_trial_role) }
    let(:user_without_organisation) { build(:user, organisation: nil) }
    let(:user_with_organisation) { build(:user, role: :editor) }

    context "when user is trial" do
      it "returns nil" do
        expect(helper.user_organisation_name(trial_user)).to be_nil
      end
    end

    context "when user does not have an organisation" do
      it "returns nil" do
        expect(helper.user_organisation_name(user_without_organisation)).to be_nil
      end
    end

    context "when user has an organisation" do
      it "returns the organisation name" do
        expect(helper.user_organisation_name(user_with_organisation)).to eq(user_with_organisation.organisation.name)
      end
    end
  end
end
