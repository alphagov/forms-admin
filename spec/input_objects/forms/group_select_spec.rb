require "rails_helper"

RSpec.describe Forms::GroupSelect, type: :model do
  let(:form) { build :form, id: 1, name: "Bye bye form", created_at: "2024-10-08T07:31:15.762Z" }
  let(:group) { build(:group, :org_has_org_admin) }
  let(:group_select) { described_class.new(group:, form:) }

  before do
    allow(FormRepository).to receive(:find).and_return(form)
    create(:form_record, id: form.id, name: form.name)
  end

  describe "groups" do
    it "returns groups" do
      create_list(:group, 3) do |g|
        g.organisation = group.organisation
        g.save!
      end

      expect(group_select.groups.count).to eq(3)
    end

    it "returns an empty array when there are no groups" do
      expect(group_select.groups).to be_empty
    end

    describe "filtered groups" do
      it "does not include the group that the form is currently in" do
        create_list(:group, 3) do |g|
          g.organisation = group.organisation
          g.save!
        end

        expect(group_select.groups.count).to be > 0
        expect(group_select.groups).not_to include(group)
      end

      context "when the organisation admin user is logged in" do
        let(:org_admin) { build(:organisation_admin_user) }

        it "returns only groups in the user's organisation" do
          create_list(:group, 3) do |g|
            g.organisation = group.organisation
            g.save!
          end
          create(:group, organisation: build(:organisation)) # Group 5

          expect(group_select.groups).not_to include(group)
          expect(group_select.groups.count).to eq(4)
        end
      end

      context "when the form is live but the target group is draft" do
        it "returns only groups that are active" do
          live_form = Form.find(form.id)
          live_form.live!

          active_group = create(:group, name: "Active", status: :active, organisation: group.organisation)
          trial_group = create(:group, name: "Trial", status: :trial, organisation: group.organisation)

          group_select = described_class.new(group: group, form:)

          expect(group_select.groups).not_to include(trial_group)
          expect(group_select.groups).to include(active_group)
        end

        context "when the form is archived but the target group is draft" do
          it "returns only groups that are active" do
            live_form = Form.find(form.id)
            live_form.archived!

            active_group = create(:group, name: "Active", status: :active, organisation: group.organisation)
            trial_group = create(:group, name: "Trial", status: :trial, organisation: group.organisation)

            group_select = described_class.new(group: group, form:)

            expect(group_select.groups).not_to include(trial_group)
            expect(group_select.groups).to include(active_group)
          end
        end
      end
    end
  end

  it "is valid when a group is present" do
    group_select.group = build(:group)

    expect(group_select).to be_valid
  end

  it "is invalid if group is blank" do
    group_select.group = nil
    expect(group_select).to be_invalid
    expect(group_select.errors[:group]).to include("Select the group you want to move this form to")
  end

  describe "to_partial_path" do
    it "returns the correct partial path" do
      expect(group_select.to_partial_path).to eq("input_objects/forms/group_select")
    end
  end
end
