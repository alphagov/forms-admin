require "rails_helper"

RSpec.describe "organisation factory" do
  it "does not duplicate organisations with same slug" do
    org1 = create :organisation, slug: "org-slug"
    org2 = create :organisation, slug: "org-slug"

    expect(org1.id).to eq org2.id
  end

  it "does not persist the organisation" do
    org = build :organisation

    expect(org).not_to be_persisted
  end
end
