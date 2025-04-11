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

    context "when a form with that name was already created in that group" do
      before do
        form_ids = (1..).each
        allow(FormRepository).to receive(:create!).and_invoke(->(**attributes) { build(:form, id: form_ids.next, **attributes) })
        allow(FormRepository).to receive(:find).and_invoke(->(form_id:) { build(:form, id: form_id) })
      end

      context "when both forms are created at the same time" do
        it "creates only one form" do
          first = Thread.new { create_form_service.create!(creator:, group:, name:) }
          second = Thread.new { create_form_service.create!(creator:, group:, name:) }

          first = first.value
          second = second.value

          expect(FormRepository).to have_received(:create!).once
          expect(second).to eq first
        end
      end

      context "when the previous form was created less than one second ago" do
        it "creates only one form" do
          first = create_form_service.create!(creator:, group:, name:)
          second = create_form_service.create!(creator:, group:, name:)

          expect(FormRepository).to have_received(:create!).once
          expect(second).to eq first
        end
      end

      context "when the previous form was created more than one second ago" do
        it "creates two forms" do
          first = travel_to 2.seconds.ago do
            create_form_service.create!(creator:, group:, name:)
          end

          second = create_form_service.create!(creator:, group:, name:)

          expect(FormRepository).to have_received(:create!).twice
          expect(second).not_to eq first
        end
      end

      context "when the previous form was created by a different user" do
        let(:other_creator) { build :user, organisation: creator.organisation }

        it "creates two forms" do
          first = create_form_service.create!(creator: other_creator, group:, name:)
          second = create_form_service.create!(creator:, group:, name:)

          expect(FormRepository).to have_received(:create!).twice
          expect(second).not_to eq first
        end
      end
    end
  end
end
