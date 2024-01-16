require "rails_helper"

describe FormListService do
  let(:forms) { build_list :form, 5 }
  let(:service) { described_class.call(forms:, current_user:, search_form:) }
  let(:search_form) { build :search_form, organisation_id: 1 }
  let(:current_user) { create :user, :with_no_org }

  describe "#data" do
    describe "caption" do
      context "when user doesn't have an organisation" do
        let(:current_user) { create :user, :with_no_org }

        it "returns generic caption" do
          expect(service.data).to include caption: I18n.t("home.your_forms")
        end
      end

      context "when user has trial role" do
        let(:current_user) { create :user, :with_trial_role }

        it "returns generic caption" do
          expect(service.data).to include caption: I18n.t("home.your_forms")
        end
      end

      context "when user has organisation" do
        let(:current_user) { create :editor_user }

        it "returns specific organisation caption" do
          organisation_name = current_user.organisation.name
          expect(service.data).to include caption: I18n.t("home.form_table_caption", organisation_name:)
        end
      end
    end

    describe "head" do
      it "contains 'Name' column heading " do
        expect(service.data[:head].first).to eq I18n.t("home.form_name_heading")
      end

      it "contains 'Status' column heading and is numeric " do
        expect(service.data[:head].last).to eq text: I18n.t("home.form_status_heading"), numeric: true
      end
    end
  end
end
