require "rails_helper"

RSpec.describe Forms::ChangeNameForm, type: :model do
  describe "name" do
    it "is invalid if blank" do
      change_name_form = described_class.new(name: "")
      error_message = I18n.t("activemodel.errors.models.forms/change_name_form.attributes.name.blank")

      change_name_form.validate(:name)

      expect(change_name_form.errors.full_messages_for(:name)).to eq(
        ["Name #{error_message}"],
      )
    end

    # More tests are required here -  e.g. that a valid submission updates the Form object
  end
end
