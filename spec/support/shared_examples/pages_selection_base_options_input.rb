RSpec.shared_examples "base selection options input" do
  describe "#include_none_of_the_above_options" do
    it "returns true and false as options" do
      expect(input.include_none_of_the_above_options).to eq [OpenStruct.new(id: "true"), OpenStruct.new(id: "false")]
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
