require "rails_helper"

RSpec.describe Forms::CopyInput, type: :model do
  describe "validations" do
    describe "name" do
      it "is invalid if blank" do
        copy_input = described_class.new(name: "")
        error_message = I18n.t("activemodel.errors.models.forms/name_input.attributes.name.blank")

        copy_input.validate(:name)

        expect(copy_input.errors.full_messages_for(:name)).to eq(
          ["Name #{error_message}"],
        )
      end

      it "is invalid if nil" do
        copy_input = described_class.new(name: nil)

        copy_input.validate(:name)

        expect(copy_input.errors[:name]).to include("Enter a name for the form")
      end

      it "is valid with a name within the length limit" do
        copy_input = described_class.new(name: "A" * 2000)

        copy_input.validate(:name)

        expect(copy_input.errors[:name]).to be_empty
      end

      it "is invalid if longer than 2000 characters" do
        copy_input = described_class.new(name: "A" * 2001)

        copy_input.validate(:name)

        expect(copy_input.errors[:name]).to include("is too long (maximum is 2000 characters)")
      end
    end
  end

  describe "#submit" do
    context "with valid attributes" do
      it "saves the form with the copied name" do
        form = create :form, name: "Original Form"
        copy_input = described_class.new(form:, name: "Copied Form")

        expect {
          copy_input.submit
        }.to change(form, :name).from("Original Form").to("Copied Form")
      end

      it "returns the result of save_draft!" do
        form = create :form
        copy_input = described_class.new(form:, name: "New Copied Form")

        result = copy_input.submit

        expect(result).to be_truthy
      end
    end

    context "with invalid attributes" do
      it "does not save the form when name is blank" do
        form = create :form, name: "Original Form"
        copy_input = described_class.new(form:, name: "")

        expect {
          copy_input.submit
        }.not_to change(form, :name)
      end

      it "returns false when name is blank" do
        form = create :form
        copy_input = described_class.new(form:, name: "")

        result = copy_input.submit

        expect(result).to be false
      end

      it "does not save the form when name exceeds maximum length" do
        form = create :form, name: "Original Form"
        copy_input = described_class.new(form:, name: "A" * 2001)

        expect {
          copy_input.submit
        }.not_to change(form, :name)
      end

      it "returns false when name exceeds maximum length" do
        form = create :form
        copy_input = described_class.new(form:, name: "A" * 2001)

        result = copy_input.submit

        expect(result).to be false
      end
    end
  end

  describe "#assign_form_values" do
    it "assigns form name to name attribute" do
      form = create :form, name: "Test Form"
      copy_input = described_class.new(form:)

      copy_input.assign_form_values

      expect(copy_input.name).to eq("Copy of Test Form")
    end

    it "returns self" do
      form = create :form
      copy_input = described_class.new(form:)

      result = copy_input.assign_form_values

      expect(result).to eq(copy_input)
    end
  end
end
