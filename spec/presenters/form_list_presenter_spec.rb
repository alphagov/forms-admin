require "rails_helper"

describe FormListPresenter do
  let(:presenter) { described_class.call(forms:, group:) }

  let(:creator) { create :user }
  let(:forms) { build_list :form, 5, :with_id, creator_id: creator.id }
  let(:group) { build :group }

  describe "#data" do
    describe "caption" do
      it "returns caption containing group name" do
        expect(presenter.data).to include caption: I18n.t("groups.form_table_caption", group_name: group.name)
      end
    end

    describe "head" do
      it "contains a 'Name', `Created by` and 'Status' column heading" do
        expect(presenter.data[:head]).to eq([I18n.t("home.form_name_heading"),
                                             { text: I18n.t("home.created_by") },
                                             { text: I18n.t("home.form_status_heading"), numeric: true }])
      end
    end

    describe "rows" do
      it "has a row for each form passed to the presenter" do
        expect(presenter.data[:rows].size).to eq forms.size
      end

      it "returns the correct data for each form" do
        presenter.data[:rows].each_with_index do |row, index|
          form = forms[index]
          expect(row).to eq([
            { text: "<a class=\"govuk-link\" href=\"/forms/#{form.id}\">#{form.name}</a>" },
            { text: creator.name.to_s },
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
