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
        copy_input = described_class.new(name: "A" * 500)

        copy_input.validate(:name)

        expect(copy_input.errors[:name]).to be_empty
      end

      it "is invalid if longer than 2000 characters" do
        copy_input = described_class.new(name: "A" * 501)

        copy_input.validate(:name)

        expect(copy_input.errors[:name]).to include(I18n.t("activemodel.errors.models.forms/name_input.attributes.name.too_long", count: 500))
      end
    end

    describe "tag" do
      it "is valid with 'draft' tag" do
        copy_input = described_class.new(tag: "draft")

        copy_input.validate(:tag)

        expect(copy_input.errors[:tag]).to be_empty
      end

      it "is valid with 'live' tag" do
        copy_input = described_class.new(tag: "live")

        copy_input.validate(:tag)

        expect(copy_input.errors[:tag]).to be_empty
      end

      it "is valid with 'archived' tag" do
        copy_input = described_class.new(tag: "archived")

        copy_input.validate(:tag)

        expect(copy_input.errors[:tag]).to be_empty
      end

      it "is invalid with an invalid tag" do
        copy_input = described_class.new(tag: "invalid")

        copy_input.validate(:tag)

        expect(copy_input.errors[:tag]).to include("\"invalid\" is not a valid tag")
      end

      it "is invalid with nil tag" do
        copy_input = described_class.new(tag: nil)

        copy_input.validate(:tag)

        expect(copy_input.errors[:tag]).to include("\"\" is not a valid tag")
      end
    end
  end

  describe "#submit" do
    context "with valid attributes" do
      it "assigns the name to the form" do
        form = create :form, name: "Original Form"
        copy_input = described_class.new(form:, name: "Copied Form", tag: "draft")

        expect {
          copy_input.submit
        }.to change(form, :name).from("Original Form").to("Copied Form")
      end

      it "returns truthy when valid" do
        form = create :form
        copy_input = described_class.new(form:, name: "New Copied Form", tag: "draft")

        result = copy_input.submit

        expect(result).to be_truthy
      end
    end

    context "with invalid attributes" do
      it "does not change the form name when name is blank" do
        form = create :form, name: "Original Form"
        copy_input = described_class.new(form:, name: "", tag: "draft")

        expect {
          copy_input.submit
        }.not_to change(form, :name)
      end

      it "returns false when name is blank" do
        form = create :form
        copy_input = described_class.new(form:, name: "", tag: "draft")

        result = copy_input.submit

        expect(result).to be false
      end

      it "does not change the form name when name exceeds maximum length" do
        form = create :form, name: "Original Form"
        copy_input = described_class.new(form:, name: "A" * 2001, tag: "draft")

        expect {
          copy_input.submit
        }.not_to change(form, :name)
      end

      it "returns false when name exceeds maximum length" do
        form = create :form
        copy_input = described_class.new(form:, name: "A" * 2001, tag: "draft")

        result = copy_input.submit

        expect(result).to be false
      end

      it "does not change the form name when tag is invalid" do
        form = create :form, name: "Original Form"
        copy_input = described_class.new(form:, name: "Copied Form", tag: "invalid")

        expect {
          copy_input.submit
        }.not_to change(form, :name)
      end

      it "returns false when tag is invalid" do
        form = create :form
        copy_input = described_class.new(form:, name: "Copied Form", tag: "invalid")

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

      expect(copy_input.name).to eq("Test Form")
    end

    it "returns self" do
      form = create :form
      copy_input = described_class.new(form:)

      result = copy_input.assign_form_values

      expect(result).to eq(copy_input)
    end
  end
end
