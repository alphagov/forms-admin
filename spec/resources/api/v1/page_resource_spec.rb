require "rails_helper"

describe Api::V1::PageResource, type: :model do
  describe "validations" do
    let(:page) { build :page, question_text: }
    let(:question_text) { "What is your address?" }

    describe "associations" do
      describe "#routing_conditions" do
        let(:page) { build :page, id: 10, routing_conditions: build_list(:condition, 3, routing_page_id: 10) }

        it "has many routing conditions" do
          expect(page.routing_conditions.length).to eq 3
          expect(page.routing_conditions).to all be_a Api::V1::ConditionResource
          expect(page.routing_conditions).to all have_attributes(routing_page_id: 10)
        end

        context "when accessing a page through ActiveResource" do
          let(:page_resource) { described_class.find(10, params: { form_id: 1 }) }

          before do
            ActiveResource::HttpMock.respond_to do |mock|
              mock.get "/api/v1/forms/1/pages/10", headers, page.to_json, 200
            end
          end

          it "has many routing conditions" do
            expect(page_resource.routing_conditions.length).to eq 3
            expect(page_resource.routing_conditions).to all be_a Api::V1::ConditionResource
            expect(page_resource.routing_conditions).to all have_attributes(routing_page_id: 10)
          end
        end
      end
    end

    describe "#question_text" do
      [nil, ""].each do |question_text|
        it "is invalid given {question_text} question text" do
          error_message = I18n.t("activemodel.errors.models.api/v1/page_resource.attributes.question_text.blank")
          page.question_text = question_text
          expect(page).not_to be_valid
          expect(page.errors[:question_text]).to include(error_message)
        end
      end

      it "is valid if question text below 200 characters" do
        expect(page).to be_valid
      end

      context "when question text 250 characters" do
        let(:question_text) { "A" * 250 }

        it "is valid" do
          expect(page).to be_valid
        end
      end

      context "when question text more 250 characters" do
        let(:question_text) { "A" * 251 }

        it "is invalid" do
          expect(page).not_to be_valid
        end

        it "has an error message" do
          page.valid?
          expect(page.errors[:question_text]).to include(I18n.t("activemodel.errors.models.api/v1/page_resource.attributes.question_text.too_long", count: 250))
        end
      end
    end

    describe "#hint_text" do
      let(:page) { build :page, hint_text: }
      let(:hint_text) { "Enter your full name as it appears in your passport" }

      it "is valid if hint text is empty" do
        page.hint_text = nil
        expect(page).to be_valid
      end

      it "is valid if hint text below 500 characters" do
        expect(page).to be_valid
      end

      context "when hint text 500 characters" do
        let(:hint_text) { "A" * 500 }

        it "is valid" do
          expect(page).to be_valid
        end
      end

      context "when hint text more than 500 characters" do
        let(:hint_text) { "A" * 501 }

        it "is invalid" do
          expect(page).not_to be_valid
        end

        it "has an error message" do
          page.valid?
          expect(page.errors[:hint_text]).to include(I18n.t("activemodel.errors.models.api/v1/page_resource.attributes.hint_text.too_long", count: 500))
        end
      end
    end
  end

  describe "#database_attributes" do
    it "includes attributes for ActiveRecord Page model" do
      page = described_class.new(id: 1, question_text: "What is your address?")
      expect(page.database_attributes).to eq({
        "id" => 1,
        "question_text" => "What is your address?",
      })
    end

    it "includes ID for associated ActiveRecord Form model" do
      page = described_class.new(id: 2, form_id: 1)
      expect(page.database_attributes).to include(
        "form_id" => 1,
      )
    end

    it "does not include attributes not in the ActiveRecord Page model" do
      page = described_class.new(id: 2, form_id: 1, has_routing_errors: true)
      expect(page.database_attributes).not_to include(
        :has_routing_errors,
      )
    end
  end

  describe "#convert_boolean_fields" do
    context "when a question is optional" do
      it "set the model attribute to true" do
        page = described_class.new(is_optional: "true")
        page.convert_boolean_fields
        expect(page.is_optional).to be true
      end

      it "returns true if it is not set to a falsey value" do
        page = described_class.new(is_optional: "something")
        page.convert_boolean_fields
        expect(page.is_optional).to be true
      end
    end

    context "when a question is required" do
      it "returns false if value is false" do
        page = described_class.new(is_optional: "false")
        page.convert_boolean_fields
        expect(page.is_optional).to be false
      end

      it "returns false if value is 0" do
        page = described_class.new(is_optional: "0")
        page.convert_boolean_fields
        expect(page.is_optional).to be false
      end
    end

    context "when a question is repeatable" do
      it "set the model attribute to true" do
        page = described_class.new(is_repeatable: "true")
        page.convert_boolean_fields
        expect(page.is_repeatable).to be true
      end

      it "returns true if it is not set to a falsey value" do
        page = described_class.new(is_repeatable: "something")
        page.convert_boolean_fields
        expect(page.is_repeatable).to be true
      end
    end

    context "when a question is not repeatable" do
      it "returns false if value is false" do
        page = described_class.new(is_repeatable: "false")
        page.convert_boolean_fields
        expect(page.is_repeatable).to be false
      end

      it "returns false if value is 0" do
        page = described_class.new(is_repeatable: "0")
        page.convert_boolean_fields
        expect(page.is_repeatable).to be false
      end
    end
  end

  describe "#move_page" do
    it "when given :up calls put(:up)" do
      page = described_class.new
      allow(page).to receive(:put).with(:up).and_return(true)
      expect(page.move_page(:up)).to be(true)
    end

    it "when given :down calls put(:down)" do
      page = described_class.new
      allow(page).to receive(:put).with(:down).and_return(true)
      expect(page.move_page(:down)).to be(true)
    end

    it "when given anything else returns false and does not call put" do
      page = described_class.new
      allow(page).to receive(:put).and_return(true)
      expect(page.move_page(:invalid_direction)).to be(false)
    end
  end

  describe "#is_optional?" do
    [
      { input: true, result: true },
      { input: "true", result: true },
      { input: false, result: false },
      { input: "false", result: false },
      { input: "0", result: false },
      { input: nil, result: false },
    ].each do |scenario|
      it "returns #{scenario[:result]} when is_optional is #{scenario[:input]}" do
        page = described_class.new(is_optional: scenario[:input])
        expect(page.is_optional?).to eq scenario[:result]
      end
    end
  end

  describe "#question_with_number" do
    let(:page) { described_class.new(question_text: "What's your name?", position: 5) }

    it "returns the page number and question text as a string" do
      expect(page.question_with_number).to eq("#{page.position}. #{page.question_text}")
    end
  end

  describe "#show_optional_suffix?" do
    let(:page) { described_class.new(is_optional:, answer_type:) }
    let(:is_optional) { "true" }
    let(:answer_type) { "national_insurance_number" }

    context "when question is optional and answer type is not selection" do
      it "returns true" do
        expect(page.show_optional_suffix?).to be true
      end
    end

    context "when question is optional and has answer_type selection" do
      let(:answer_type) { "selection" }

      it "returns false" do
        expect(page.show_optional_suffix?).to be false
      end
    end

    context "when question is not optional and answer type is not selection" do
      let(:is_optional) { "false" }

      it "returns false" do
        expect(page.show_optional_suffix?).to be false
      end
    end
  end
end
