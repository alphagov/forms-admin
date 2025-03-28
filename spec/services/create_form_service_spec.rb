require "rails_helper"

RSpec.describe CreateFormService do
  subject(:create_form_service) do
    described_class.new
  end

  let(:creator) { build :user, id: 100 }
  let(:group) { build :group, id: 1000, organisation: creator.organisation }
  let(:name) { "Test form" }

  describe "#create!" do
    before do
      allow(FormRepository).to receive(:create!).and_invoke(->(**attributes) { build(:form, id: 1, **attributes) })
    end

    it "creates a form" do
      create_form_service.create!(creator:, group:, name:)

      expect(FormRepository).to have_received(:create!).with(creator_id: 100, name: "Test form")
    end

    it "creates a group_form record" do
      create_form_service.create!(creator:, group:, name:)

      expect(GroupForm.last).to have_attributes(form_id: 1, group_id: 1000)
    end
  end
end
