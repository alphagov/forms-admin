RSpec.shared_examples "base selection options input" do
  describe "#include_none_of_the_above_options" do
    let(:describe_none_of_the_above_enabled) { true }

    before do
      allow(FeatureService).to receive(:enabled?).with(:describe_none_of_the_above_enabled)
                                                 .and_return(describe_none_of_the_above_enabled)
    end

    context "when the describe_none_of_the_above_enabled feature is enabled" do
      it "includes an option for yes_with_question" do
        expect(input.include_none_of_the_above_options).to contain_exactly(OpenStruct.new(id: "yes"), OpenStruct.new(id: "yes_with_question"), OpenStruct.new(id: "no"))
      end
    end

    context "when the describe_none_of_the_above_enabled feature is disabled" do
      let(:describe_none_of_the_above_enabled) { false }

      it "does not include an option for yes_with_question" do
        expect(input.include_none_of_the_above_options).to contain_exactly(OpenStruct.new(id: "yes"), OpenStruct.new(id: "no"))
      end
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
end
