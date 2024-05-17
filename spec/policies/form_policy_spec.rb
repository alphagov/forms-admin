require "rails_helper"

describe FormPolicy do
  subject(:policy) { described_class.new(user, form) }

  let(:organisation) { build :organisation, id: 1, slug: "gds" }
  let(:form) { build :form, id: 1, organisation_id: 1, creator_id: 123 }
  let(:group) { create(:group, name: "Group 1", organisation:) }
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

    context "when form is not in a group" do
      let(:group) { nil }

      context "with an editor role" do
        let(:user) { build :editor_user, organisation: }

        it { is_expected.to permit_actions(%i[can_view_form]) }

        context "but from another organisation" do
          let(:organisation) { build :organisation, id: 2, slug: "non-gds" }

          it { is_expected.to forbid_actions(%i[can_view_form]) }
        end

        context "with an organisation not in the organisation table" do
          let(:user) { build :editor_user, :with_unknown_org, organisation_slug: "gds" }

          it "raises an error" do
            expect { policy }.to raise_error FormPolicy::UserMissingOrganisationError
          end
        end
      end

      context "with a trial role" do
        let(:user) { build :user, :with_trial_role, id: 123 }

        context "when the user created the form" do
          it { is_expected.to permit_actions(%i[can_view_form]) }
        end

        context "when the user didn't create the form" do
          let(:user) { build :user, :with_trial_role, id: 321 }

          it { is_expected.to forbid_actions(%i[can_view_form]) }

          context "but the user belongs to the organisation that the form belongs to" do
            let(:user) { build :user, role: :trial, organisation_slug: "gds", id: 321 }

            it { is_expected.to forbid_actions(%i[can_view_form]) }
          end
        end
      end
    end
  end

  %i[can_change_form_submission_email can_make_form_live].each do |permission|
    describe "#{permission}?" do
      context "when form is not in a group" do
        let(:group) { nil }

        context "with a form editor" do
          it { is_expected.to permit_actions(permission) }

          context "but from another organisation" do
            let(:organisation) { build :organisation, id: 2, slug: "non-gds" }

            it { is_expected.to forbid_actions(permission) }
          end
        end

        context "with a trial role" do
          let(:form) { build :form, id: 1, organisation_id: nil, creator_id: 123 }

          context "when the user created the form" do
            let(:user) { build :user, :with_trial_role, id: 123 }

            it { is_expected.to forbid_actions(permission) }
          end

          context "when the user didn't create the form" do
            context "with a different user" do
              let(:user) { build :user, id: 321 }

              it { is_expected.to forbid_actions(permission) }
            end

            context "without a form creator" do
              let(:form) { build :form, id: 1, organisation_id: nil, creator_id: nil }

              it { is_expected.to forbid_actions(permission) }
            end
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

  describe FormPolicy::Scope do
    let(:policy_scope) { described_class.new(user, scope) }
    let(:scope) { class_double(Form) }
    let(:user) { build(:user, :with_trial_role) }

    describe "#resolve" do
      context "when user is on trial" do
        before do
          allow(scope).to receive(:where).with(creator_id: user.id)
        end

        it "returns only their records" do
          policy_scope.resolve
          expect(scope).to have_received(:where).with(creator_id: user.id)
        end
      end

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
