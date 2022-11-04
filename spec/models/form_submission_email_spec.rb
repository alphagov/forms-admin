require "rails_helper"

describe FormSubmissionEmail, type: :model do
  let(:subject) { described_class.new }

  describe "validations" do
    it "requires a form_id" do
      subject.form_id = 123_456
      expect(subject).to be_valid
    end

    it ""
  end
end
