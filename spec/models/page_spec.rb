require "rails_helper"

describe Page, type: :model do
  describe "#convert_is_optional_to_boolean" do
    context "when a question is optional" do
      it "set the model attribute to true" do
        page = described_class.new(is_optional: "true")
        page.convert_is_optional_to_boolean
        expect(page.is_optional).to be true
      end
    end

    context "when a question is required" do
      it "clears the model attribute is false" do
        page = described_class.new(is_optional: "false")
        page.convert_is_optional_to_boolean
        expect(page.is_optional).to be nil
      end

      it "clears the model attribute if value is 0" do
        page = described_class.new(is_optional: "0")
        page.convert_is_optional_to_boolean
        expect(page.is_optional).to be nil
      end

      it "clears the model attribute if its not set to 'true'" do
        page = described_class.new(is_optional: "something")
        page.convert_is_optional_to_boolean
        expect(page.is_optional).to be nil
      end
    end
  end

  describe "#move_page" do
    it "when given :up calls put(:up)" do
      page = described_class.new
      allow(page).to receive(:put).with(:up).and_return(true)
      expect(page.move_page(:up)).to eq(true)
    end

    it "when given :down calls put(:down)" do
      page = described_class.new
      allow(page).to receive(:put).with(:down).and_return(true)
      expect(page.move_page(:down)).to eq(true)
    end

    it "when given anything else returns false and does not call put" do
      page = described_class.new
      allow(page).to receive(:put).and_return(true)
      expect(page.move_page(:invalid_direction)).to eq(false)
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

  describe "#load_from_session" do
    let(:page) { described_class.new(answer_type: "date") }
    let(:session_mock) { { page: {} } }

    context "when the key is not present in the session" do
      it "returns the value from the page" do
        page.load_from_session(session_mock, %w[answer_type])
        expect(page.answer_type).to eq("date")
      end
    end

    context "when the key is nil in the session" do
      let(:session_mock) { { page: { answer_type: nil } } }

      it "returns the value from the page" do
        page.load_from_session(session_mock, %w[answer_type])
        expect(page.answer_type).to eq("date")
      end
    end

    context "when the key is present in the session" do
      let(:session_mock) { { page: { "answer_type" => "address" } } }

      it "returns the value from the session" do
        page.load_from_session(session_mock, %w[answer_type])
        expect(page.answer_type).to eq("address")
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
