require "rails_helper"

describe PageOptionsService do
  subject(:page_options_service) do
    described_class.new(page:)
  end

  describe "#all_options_for_answer_type" do
    context "with uk and interational address" do
      let(:page) { build :page, :with_address_settings, uk_address: "true", international_address: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: "Answer type", value: "Address" },
           { key: "Optional", value: "No" },
           { key: "Input type", value: "UK and international addresses" }],
        )
      end
    end

    context "with interational address only" do
      let(:page) { build :page, :with_address_settings, uk_address: "false", international_address: "true" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: "Answer type", value: "Address" },
           { key: "Optional", value: "No" },
           { key: "Input type", value: "International addresses" }],
        )
      end
    end

    context "with uk address" do
      let(:page) { build :page, :with_address_settings, international_address: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: "Answer type", value: "Address" },
           { key: "Optional", value: "No" },
           { key: "Input type", value: "UK addresses" }],
        )
      end
    end

    context "with address and not international or UK" do
      let(:page) { build :page, :with_address_settings, uk_address: "false", international_address: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq(
          [{ key: "Answer type", value: "Address" },
           { key: "Optional", value: "No" },
           { key: "Input type", value: "International addresses" }],
        )
      end
    end

    context "with date of birth" do
      let(:page) { build :page, :with_date_settings, input_type: "date_of_birth" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: "Answer type", value: "Date" },
          { key: "Optional", value: "No" },
          { key: "Input type", value: "Date of birth" },
        ])
      end
    end

    context "with date other_date" do
      let(:page) { build :page, :with_date_settings, input_type: "other_date" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: "Answer type", value: "Date" },
          { key: "Optional", value: "No" },
          { key: "Input type", value: "Other date" },
        ])
      end
    end

    context "with short text" do
      let(:page) { build :page, :with_text_settings, input_type: "single_line" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: "Answer type", value: "Text" },
          { key: "Optional", value: "No" },
          { key: "Input type", value: "Single line of text" },
        ])
      end
    end

    context "with long text" do
      let(:page) { build :page, :with_text_settings, input_type: "long_text" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: "Answer type", value: "Text" },
          { key: "Optional", value: "No" },
          { key: "Input type", value: "More than a single line of text" },
        ])
      end
    end

    context "with selection" do
      let(:page) { build :page, :with_selections_settings }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: "Answer type", value: "Selection from a list" },
          { key: "Options", value: "Option 1, Option 2" },
          { key: "People can only select one option", value: "Yes" },
          { key: "Include an option for ‘None of the above’", value: "No" },
        ])
      end
    end

    context "with selection not only_one_option " do
      let(:page) { build :page, :with_selections_settings, only_one_option: "false" }

      it "returns the correct options" do
        expect(page_options_service.all_options_for_answer_type).to eq([
          { key: "Answer type", value: "Selection from a list" },
          { key: "Options", value: "Option 1, Option 2" },
          { key: "People can only select one option", value: "No" },
          { key: "Include an option for ‘None of the above’", value: "No" },
        ])
      end
    end

    [
      ["national_insurance_number", "National Insurance number"],
      %w[number Number],
      ["email", "Email address"],
      ["phone_number", "Phone number"],
      ["single_line", "Single line of text"],
      ["organisation_name", "Company or organisation’s name"],
      ["long_text", "Multiple lines of text"],
    ].each do |answer_type, expected_options|
      context "with #{answer_type}" do
        let(:page) { build :page, answer_type: }

        it "returns the correct options" do
          expect(page_options_service.all_options_for_answer_type).to eq([
            { key: "Answer type", value: expected_options },
            { key: "Optional", value: "No" },
          ])
        end
      end
    end
  end
end
