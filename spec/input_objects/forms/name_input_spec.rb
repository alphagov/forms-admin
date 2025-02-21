require "rails_helper"

RSpec.describe Forms::NameInput, type: :model do
  describe "name" do
    it "is invalid if blank" do
      name_input = described_class.new(name: "")
      error_message = I18n.t("activemodel.errors.models.forms/name_input.attributes.name.blank")

      name_input.validate(:name)

      expect(name_input.errors.full_messages_for(:name)).to eq(
        [ "Name #{error_message}" ],
      )
    end
  end

  describe "#submit" do
    context "with valid attributes" do
      it "saves the form" do
        form = build :form
        name_input = described_class.new(form:, name: "New Form")

        allow(FormRepository).to receive(:save!).and_return({ id: 1, name: "New Form" })

        expect {
          name_input.submit
        }.to change(form, :name).to("New Form")
      end
    end

    context "with invalid attributes" do
      it "does not save the form" do
        form = build :form
        name_input = described_class.new(form:, name: "")

        expect {
          name_input.submit
        }.not_to change(form, :name)
      end
    end
  end
end
