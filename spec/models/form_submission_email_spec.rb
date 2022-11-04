require "rails_helper"

describe FormSubmissionEmail, type: :model do
  subject(:form_submission_email) { described_class.new }

  describe "validations" do
    it "requires a form_id" do
      form_submission_email.form_id = 123_456
      expect(form_submission_email).to be_valid
    end
  end
end
