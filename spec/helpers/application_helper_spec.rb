require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#link_to_runner" do
    it "returns url to the form-runners form" do
      expect(helper.link_to_runner("example.com", 2)).to eq "example.com/preview-form/2"
    end
  end
end
