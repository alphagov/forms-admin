require "rails_helper"

RSpec.describe "reports/last_signed_in_at" do
  let(:users) do
    [
      create(:user, provider: :auth0, last_signed_in_at: (1.year + 2.months).ago),
      create(:user, provider: :auth0, last_signed_in_at: nil),
      create(:user, provider: :gds, last_signed_in_at: nil),
    ]
  end

  before do
    users

    render
  end

  describe "tables of when users last signed in" do
    specify "users who are in one table are not duplicated in another" do
      users.each do |user|
        expect(rendered).to have_text(user.email, maximum: 1)
      end
    end
  end
end
