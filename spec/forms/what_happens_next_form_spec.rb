require "rails_helper"

RSpec.describe Forms::WhatHappensNextForm, type: :model do
  context "when form is live" do
    let(:form) do
      build(:form, :live)
    end

    describe "validations" do
      describe "Character length" do
        it "is valid if less than 2000 characters" do
          what_happens_next_form = described_class.new(form:, what_happens_next_text: "a")

          expect(what_happens_next_form).to be_valid
        end

        it "is valid if 2000 characters" do
          what_happens_next_form = described_class.new(form:, what_happens_next_text: "a" * 2000)

          expect(what_happens_next_form).to be_valid
        end

        it "is invalid if more than 2000 characters" do
          what_happens_next_form = described_class.new(form:, what_happens_next_text: "a" * 2001)
          error_message = I18n.t("activemodel.errors.models.forms/what_happens_next_form.attributes.what_happens_next_text.too_long")

          expect(what_happens_next_form).not_to be_valid

          what_happens_next_form.validate(:what_happens_next_text)

          expect(what_happens_next_form.errors.full_messages_for(:what_happens_next_text)).to include(
            "What happens next text #{error_message}",
          )
        end
      end

      it "is invalid if blank" do
        what_happens_next_form = described_class.new(form:, what_happens_next_text: "")

        expect(what_happens_next_form).not_to be_valid
      end
      # More tests are required here -  e.g. that a valid submission updates the Form object
    end

    describe "#submit" do
      it "returns false if the data is invalid" do
        what_happens_next_form = described_class.new(form:, what_happens_next_text: ("abc" * 2001))
        expect(what_happens_next_form.submit).to eq false
      end

      it "sets the form's attribute value" do
        form = OpenStruct.new(what_happens_next_text: "abc")
        what_happens_next_form = described_class.new(form:)
        what_happens_next_form.what_happens_next_text = "Thank you for submitting"
        what_happens_next_form.submit
        expect(what_happens_next_form.form.what_happens_next_text).to eq "Thank you for submitting"
      end
    end
  end

  context "when form is not live" do
    let(:form) do
      build(:form)
    end

    describe "validations" do
      describe "Character length" do
        it "is valid if less than 2000 characters" do
          what_happens_next_form = described_class.new(form:, what_happens_next_text: "a")

          expect(what_happens_next_form).to be_valid
        end

        it "is valid if 2000 characters" do
          what_happens_next_form = described_class.new(form:, what_happens_next_text: "a" * 2000)

          expect(what_happens_next_form).to be_valid
        end

        it "is invalid if more than 2000 characters" do
          what_happens_next_form = described_class.new(form:, what_happens_next_text: "a" * 2001)
          error_message = I18n.t("activemodel.errors.models.forms/what_happens_next_form.attributes.what_happens_next_text.too_long")

          expect(what_happens_next_form).not_to be_valid

          what_happens_next_form.validate(:what_happens_next_text)

          expect(what_happens_next_form.errors.full_messages_for(:what_happens_next_text)).to include(
            "What happens next text #{error_message}",
          )
        end
      end

      it "is valid if blank" do
        what_happens_next_form = described_class.new(form:, what_happens_next_text: "")

        expect(what_happens_next_form).to be_valid
      end
      # More tests are required here -  e.g. that a valid submission updates the Form object
    end

    describe "#submit" do
      it "returns false if the data is invalid" do
        what_happens_next_form = described_class.new(form:, what_happens_next_text: ("abc" * 2001))
        expect(what_happens_next_form.submit).to eq false
      end

      it "sets the form's attribute value" do
        form = OpenStruct.new(what_happens_next_text: "abc")
        what_happens_next_form = described_class.new(form:)
        what_happens_next_form.what_happens_next_text = "Thank you for submitting"
        what_happens_next_form.submit
        expect(what_happens_next_form.form.what_happens_next_text).to eq "Thank you for submitting"
      end
    end
  end
end
