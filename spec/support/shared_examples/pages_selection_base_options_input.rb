RSpec.shared_examples "base selection options input" do
  describe "#include_none_of_the_above_options" do
    it "has the expected radio options" do
      expect(input.include_none_of_the_above_options).to contain_exactly(OpenStruct.new(id: "yes"), OpenStruct.new(id: "yes_with_question"), OpenStruct.new(id: "no"))
    end
  end

  describe "#only_one_option?" do
    context "when only_one_option is 'true'" do
      let(:only_one_option) { "true" }

      it { expect(input.only_one_option?).to be true }
    end

    context "when only_one_option is 'false'" do
      let(:only_one_option) { "false" }

      it { expect(input.only_one_option?).to be false }
    end
  end

  describe "#maximum_options" do
    context "when only_one_option is true" do
      let(:only_one_option) { "true" }

      it { expect(input.maximum_options).to eq 1000 }
    end

    context "when only_one_option is false" do
      let(:only_one_option) { "false" }

      it { expect(input.maximum_options).to eq 30 }
    end
  end

  describe "#submit handling for include_none_of_the_above" do
    context "when there is an existing none_of_the_above_question" do
      before do
        draft_question.answer_settings = { none_of_the_above_question: { question_text: "Enter something" }, only_one_option: only_one_option }
      end

      it "keeps existing none_of_the_above_question when yes_with_question selected" do
        input.include_none_of_the_above = "yes_with_question"
        input.submit
        expect(draft_question.reload.answer_settings).to include(none_of_the_above_question: { question_text: "Enter something" })
      end

      it "deletes none_of_the_above_question when yes selected" do
        input.include_none_of_the_above = "yes"
        input.submit
        expect(draft_question.reload.answer_settings).not_to have_key(:none_of_the_above_question)
      end

      it "deletes none_of_the_above_question when no selected" do
        input.include_none_of_the_above = "no"
        input.submit
        expect(draft_question.reload.answer_settings).not_to have_key(:none_of_the_above_question)
      end
    end

    context "when there is no existing none_of_the_above_question" do
      it "adds an empty hash for none_of_the_above_question to the answer_settings when yes_with_question selected" do
        input.include_none_of_the_above = "yes_with_question"
        input.submit
        expect(draft_question.reload.answer_settings).to include(none_of_the_above_question: {})
      end
    end
  end
end
