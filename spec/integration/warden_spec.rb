require "rails_helper"

RSpec.describe "usage of Warden framework" do
  describe "after_authentication callbacks" do
    let(:user) { create :user }

    before do
      set_run_callbacks(true)
    end

    after do
      set_run_callbacks(false)
    end

    it "notifies the user model that the user has signed in" do
      allow(user).to receive(:signed_in!)

      login_as user
      get "/"

      expect(user).to have_received(:signed_in!)
    end
  end
end
