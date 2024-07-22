require "rails_helper"

describe FormPolicy do
  subject(:policy) { described_class.new(user, form) }

  let(:organisation) { build :organisation, :with_signed_mou, id: 1 }
  let(:form) { build :form, id: 1, organisation_id: 1, creator_id: 123 }
  let(:group) { create(:group, name: "Group 1", organisation:, status: group_status) }
  let(:group_status) { :trial }
  let(:user) { build :editor_user, organisation: }

  before do
    if group.present?
      GroupForm.create!(form_id: form.id, group_id: group.id)
    end
  end

  describe "#initialize?" do
    context "when user does not belong to an organisation" do
      context "with editor role" do
        let(:user) { build :editor_user, :with_no_org }

        it "raises an error" do
          expect { policy }.to raise_error FormPolicy::UserMissingOrganisationError
        end
      end

      context "with trial role" do
        let(:user) { build :user, :with_trial_role }

        it "does not raise an error" do
          expect { policy }.not_to raise_error
        end
      end
    end
  end

  describe "#can_view_form?" do
    context "when user is in the group" do
      before do
        Membership.create!(user:, group:, added_by: user)
      end

      it { is_expected.to permit_actions(%i[can_view_form]) }
    end

    context "when user is not in the group" do
      it { is_expected.to forbid_actions(%i[can_view_form]) }

      context "but user is a super_admin" do
        let(:user) { build :super_admin_user, organisation: }

        it { is_expected.to permit_actions(%i[can_view_form]) }
      end

      context "but user is an organisation_admin" do
        context "and the user is in the same organisation as the group" do
          let(:user) { build :organisation_admin_user, organisation: }

          it { is_expected.to permit_actions(%i[can_view_form]) }
        end

        context "and the user is not in the same organisation as the group" do
          let(:other_organisation) { build :organisation, id: 2, slug: "other" }

          let(:user) { build :organisation_admin_user, organisation: other_organisation }

          it { is_expected.to forbid_actions(%i[can_view_form]) }
        end
      end
    end

    context "with a super_admin role" do
      let(:user) { build :super_admin_user, organisation: }

      it { is_expected.to permit_actions(%i[can_view_form]) }

      context "and a form from another organisation" do
        let(:organisation) { build :organisation, id: 2, slug: "non-gds" }

        it { is_expected.to permit_actions(%i[can_view_form]) }
      end
    end
  end

  describe "#can_make_form_live?" do
    context "with the groups feature enabled" do
      let(:group_role) { :editor }

      before do
        Membership.create!(user:, group:, added_by: user, role: group_role)
      end

      context "and the group status is not active" do
        let(:group_status) { :trial }

        it { is_expected.to forbid_action(:can_make_form_live) }
      end

      context "and the form is in the user's group" do
        let(:group_role) { :editor }

        before do
          Membership.create!(user:, group:, added_by: user, role: group_role)
        end

        context "and the group status is not active" do
          let(:group_status) { :trial }

          it { is_expected.to forbid_action(:can_make_form_live) }
        end

        context "and the group status is active" do
          let(:group_status) { :active }

          context "and the user's role is super admin" do
            let(:user) { build :super_admin_user, organisation: }

            it { is_expected.to permit_action(:can_make_form_live) }
          end

          context "and the user is organisation admin for the group" do
            let(:user) { build :organisation_admin_user, organisation: }

            it { is_expected.to permit_action(:can_make_form_live) }
          end

          context "and the user's role within the group is group admin" do
            let(:group_role) { :group_admin }

            it { is_expected.to permit_action(:can_make_form_live) }
          end

          context "and the user's role within the group is editor" do
            it { is_expected.to forbid_action(:can_make_form_live) }
          end
        end
      end
    end
  end

  describe "#can_add_page_routing_conditions?" do
    let(:form) { build :form, id: 1, pages:, organisation_id: 1 }
    let(:pages) { [] }

    context "and the form has one page" do
      let(:pages) { [(build :page, position: 1, id: 1)] }

      it { is_expected.to forbid_actions(%i[can_add_page_routing_conditions]) }
    end

    context "and the form has two or more pages" do
      let(:pages) { [(build :page, position: 1, id: 1), (build :page, position: 2, id: 2)] }

      context "and the form does not have a selection question" do
        it { is_expected.to forbid_actions(%i[can_add_page_routing_conditions]) }
      end

      context "and the form only has a selection question with an existing route" do
        let(:routing_conditions) { [(build :condition, id: 1, check_page_id: 1, answer_value: "Wales", goto_pageid: 2)] }
        let(:pages) { [(build :page, :with_selections_settings, position: 1, id: 1, routing_conditions:), (build :page, position: 2, id: 2)] }

        it { is_expected.to forbid_actions(%i[can_add_page_routing_conditions]) }
      end

      context "and the form has a selection question without an existing route" do
        context "and the available selection question is the last page in the form" do
          let(:routing_conditions) { [(build :condition, id: 1, check_page_id: 1, answer_value: "Wales", goto_pageid: 2)] }
          let(:pages) { [(build :page, :with_selections_settings, position: 1, id: 1, routing_conditions:), (build :page, position: 2, id: 2), (build :page, :with_selections_settings, position: 3, id: 3)] }

          it { is_expected.to forbid_actions(%i[can_add_page_routing_conditions]) }
        end

        context "and the available selection question is not the last page in the form" do
          let(:routing_conditions) { [(build :condition, id: 1, check_page_id: 1, answer_value: "Wales", goto_pageid: 2)] }
          let(:pages) { [(build :page, :with_selections_settings, position: 1, id: 1, routing_conditions:), (build :page, :with_selections_settings, position: 2, id: 2), (build :page, position: 3, id: 3)] }

          it { is_expected.to permit_actions(%i[can_add_page_routing_conditions]) }
        end
      end
    end
  end

  describe "#can_administer_group?" do
    let(:group) { create(:group, name: "Group 1", organisation:) }
    let(:group_role) { :editor }

    before do
      Membership.create!(user:, group:, added_by: user, role: group_role)
    end

    context "when the user is a super admin" do
      let(:user) { build :super_admin_user }

      it { is_expected.to permit_action(:can_administer_group) }
    end

    context "when the user is an organisation admin" do
      let(:user) { build :organisation_admin_user }

      it { is_expected.to permit_action(:can_administer_group) }
    end

    context "when the user is a group admin" do
      let(:group_role) { :group_admin }

      it { is_expected.to permit_action(:can_administer_group) }
    end

    context "when the user is an editor" do
      it { is_expected.to forbid_action(:can_administer_group) }
    end
  end

  describe FormPolicy::Scope do
    let(:policy_scope) { described_class.new(user, scope) }
    let(:scope) { class_double(Form) }
    let(:user) { build(:user, :with_trial_role) }

    describe "#resolve" do
      context "when user has an editor role" do
        let(:user) { build(:editor_user) }

        before do
          allow(scope).to receive(:where).with(organisation_id: user.organisation.id)
        end

        it "returns only their organisation records" do
          policy_scope.resolve
          expect(scope).to have_received(:where).with(organisation_id: user.organisation.id)
        end
      end

      context "when user has an super_admin role" do
        let(:user) { build(:super_admin_user) }

        before do
          allow(scope).to receive(:where)
        end

        it "is not scoped" do
          policy_scope.resolve
          expect(scope).not_to have_received(:where)
        end
      end
    end

    describe "#initialize" do
      context "when user belongs to an organisation" do
        before { allow(user).to receive(:organisation_valid?).and_return(true) }

        it "does not throw an exception" do
          expect { policy_scope }.not_to raise_error
        end
      end

      context "when user does not belong to an organisation" do
        before { allow(user).to receive(:organisation_valid?).and_return(false) }

        it "throws a FormPolicy::UserMissingOrganisationError exception" do
          expect { policy_scope }.to raise_error(FormPolicy::UserMissingOrganisationError, "Missing required attribute organisation_id")
        end
      end
    end
  end
end
