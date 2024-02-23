require "rails_helper"

describe FormListService do
  let(:service) { described_class.call(forms:, current_user:, organisation:) }

  let(:forms) { build_list :form, 5, :with_id, creator_id: current_user.id }
  let(:organisation) { OpenStruct.new(name: "Organisation 1") }
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
      context "when user is editor" do
        let(:current_user) { create :editor_user }

        it "contains a 'Name', `Created by` and 'Status' column heading" do
          expect(service.data[:head]).to eq([I18n.t("home.form_name_heading"),
                                             { text: I18n.t("home.created_by") },
                                             { text: I18n.t("home.form_status_heading"), numeric: true }])
        end
      end

      context "when user is super admin" do
        let(:current_user) { create :super_admin_user }

        it "contains a 'Name', `Created by` and 'Status' column heading" do
          expect(service.data[:head]).to eq([I18n.t("home.form_name_heading"),
                                             { text: I18n.t("home.created_by") },
                                             { text: I18n.t("home.form_status_heading"), numeric: true }])
        end
      end

      context "when user is trial" do
        let(:current_user) { create :user, :with_trial_role }

        it "contains a 'Name' and 'Status' column heading" do
          expect(service.data[:head]).to eq([I18n.t("home.form_name_heading"), { text: I18n.t("home.form_status_heading"), numeric: true }])
        end
      end
    end

    describe "rows" do
      context "when user is trial user" do
        let(:current_user) { create :user, :with_trial_role }

        it "has a row for each form passed to the service" do
          expect(service.data[:rows].size).to eq forms.size
        end

        it "returns the correct data for each form" do
          service.data[:rows].each_with_index do |row, index|
            form = forms[index]
            expect(row).to eq([
              { text: "<a class=\"govuk-link\" href=\"/forms/#{form.id}\">#{form.name}</a>" },
              {
                numeric: true,
                text: "<div class='app-form-states'><strong class=\"govuk-tag govuk-tag--yellow\">Draft</strong>\n</div>",
              },
            ])
          end
        end
      end

      context "when user is editor" do
        let(:current_user) { create :editor_user }

        it "contains 3 columns" do
          expect(service.data[:rows].first.size).to eq 3
        end

        it "returns the created by name" do
          service.data[:rows].each_with_index do |row, index|
            form = forms[index]
            expect(row).to eq([
              { text: "<a class=\"govuk-link\" href=\"/forms/#{form.id}\">#{form.name}</a>" },
              { text: current_user.name },
              {
                numeric: true,
                text: "<div class='app-form-states'><strong class=\"govuk-tag govuk-tag--yellow\">Draft</strong>\n</div>",
              },
            ])
          end
        end
      end

      context "when user is super admin" do
        let(:current_user) { create :super_admin_user }

        it "contains 3 columns" do
          expect(service.data[:rows].first.size).to eq 3
        end

        it "returns the created by name" do
          service.data[:rows].each_with_index do |row, index|
            form = forms[index]
            expect(row).to eq([
              { text: "<a class=\"govuk-link\" href=\"/forms/#{form.id}\">#{form.name}</a>" },
              { text: current_user.name },
              {
                numeric: true,
                text: "<div class='app-form-states'><strong class=\"govuk-tag govuk-tag--yellow\">Draft</strong>\n</div>",
              },
            ])
          end
        end
      end
    end
  end
end
