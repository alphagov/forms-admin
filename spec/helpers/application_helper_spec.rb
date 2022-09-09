require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#link_to_runner" do
    it "returns url to the form-runners form" do
      expect(helper.link_to_runner("example.com", 2)).to eq "example.com/form/2"
    end
  end

  describe "#form_is_live" do
    context "when given a draft form" do
      let(:form) do
        Form.new(
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
          live_at: ""
        )
      end
      it "returns false" do
        expect(helper.form_is_live(form)).to be(false)
      end
    end

    context "when given a live form" do
      let(:form) do
        Form.new(
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
          live_at: "2020-09-09 11:01:25 +0100"
        )
      end
      it "returns false" do
        expect(helper.form_is_live(form)).to be(true)
      end
    end
  end
end
