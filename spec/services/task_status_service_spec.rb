require "rails_helper"

describe TaskStatusService do
  let(:task_status_service) do
    described_class.new(form:)
  end

  let(:current_user) { build(:user, role: :editor) }

  describe "statuses" do
    describe "name status" do
      let(:form) { build(:form, :new_form) }

      it "returns the correct default value" do
        expect(task_status_service.task_statuses[:name_status]).to eq :completed
      end
    end

    describe "pages status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form) }

        it "returns the correct default value" do
          expect(task_status_service.task_statuses[:pages_status]).to eq :not_started
        end
      end

      context "with a form which has pages" do
        let(:form) { build(:form, :new_form, :with_pages, question_section_completed: false) }

        it "returns the in progress status" do
          expect(task_status_service.task_statuses[:pages_status]).to eq :in_progress
        end

        context "and questions marked completed" do
          let(:form) { build(:form, :new_form, :with_pages, question_section_completed: true) }

          it "returns the completed status" do
            expect(task_status_service.task_statuses[:pages_status]).to eq :completed
          end
        end
      end
    end

    describe "declaration status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form) }

        it "returns the correct default value" do
          expect(task_status_service.task_statuses[:declaration_status]).to eq :not_started
        end
      end

      context "with a form which has no declaration content and is marked incomplete" do
        let(:form) { build(:form, declaration_section_completed: false) }

        it "returns the not started status" do
          expect(task_status_service.task_statuses[:declaration_status]).to eq :not_started
        end
      end

      context "with a form which has declaration content and is marked incomplete" do
        let(:form) { build(:form, declaration_text: "I understand the implications", declaration_section_completed: false) }

        it "returns the in progress status" do
          expect(task_status_service.task_statuses[:declaration_status]).to eq :in_progress
        end
      end

      context "with a form which has a declaration marked complete" do
        let(:form) { build(:form, declaration_section_completed: true) }

        it "returns the completed status" do
          expect(task_status_service.task_statuses[:declaration_status]).to eq :completed
        end
      end
    end

    describe "what happens next status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form) }

        it "returns the correct default value" do
          expect(task_status_service.task_statuses[:what_happens_next_status]).to eq :not_started
        end
      end

      context "with a form which has a what_happens_next_markdown" do
        let(:form) { build(:form, :new_form, what_happens_next_markdown: "We usually respond to applications within 10 working days.") }

        it "returns the completed status" do
          expect(task_status_service.task_statuses[:what_happens_next_status]).to eq :completed
        end
      end
    end

    describe "payment link status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form) }

        it "returns the correct default value" do
          expect(task_status_service.task_statuses[:payment_link_status]).to eq :optional
        end
      end

      context "with a form with a payment link" do
        let(:form) { build(:form, :new_form, payment_url: Faker::Internet.url(host: "gov.uk")) }

        it "returns the completed status" do
          expect(task_status_service.task_statuses[:payment_link_status]).to eq :completed
        end
      end
    end

    describe "privacy policy status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form) }

        it "returns the correct default value" do
          expect(task_status_service.task_statuses[:privacy_policy_status]).to eq :not_started
        end
      end

      context "with a form which has a privacy policy section" do
        let(:form) { build(:form, :new_form, privacy_policy_url: Faker::Internet.url(host: "gov.uk")) }

        it "returns the in progress status" do
          expect(task_status_service.task_statuses[:privacy_policy_status]).to eq :completed
        end
      end
    end

    describe "support contact details status status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form) }

        it "returns the correct default value" do
          expect(task_status_service.task_statuses[:support_contact_details_status]).to eq :not_started
        end
      end

      context "with a form which has contact details set" do
        let(:form) { build(:form, :new_form, :with_support) }

        it "returns the in progress status" do
          expect(task_status_service.task_statuses[:support_contact_details_status]).to eq :completed
        end
      end
    end

    describe "receive_csv_status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form) }

        it "returns optional" do
          expect(task_status_service.task_statuses[:receive_csv_status]).to eq :optional
        end
      end

      context "with submission_type set to 'email'" do
        let(:form) { build(:form, :new_form, submission_type: "email") }

        it "returns optional" do
          expect(task_status_service.task_statuses[:receive_csv_status]).to eq :optional
        end
      end

      context "with submission_type set to 'email_with_csv'" do
        let(:form) { build(:form, :new_form, submission_type: "email_with_csv") }

        it "returns completed" do
          expect(task_status_service.task_statuses[:receive_csv_status]).to eq :completed
        end
      end
    end

    describe "share_preview_status" do
      context "with share_preview_completed set to false" do
        context "when the form does not have any pages" do
          let(:form) { build(:form, :new_form) }

          it "returns cannot_start" do
            expect(task_status_service.task_statuses[:share_preview_status]).to eq :cannot_start
          end
        end

        context "when the form has pages" do
          let(:form) { build(:form, :with_pages) }

          it "returns not_started" do
            expect(task_status_service.task_statuses[:share_preview_status]).to eq :not_started
          end
        end
      end

      context "with share_preview_completed set to true" do
        context "when the form does not have any pages" do
          let(:form) { build(:form, :new_form, share_preview_completed: true) }

          it "returns cannot_start" do
            expect(task_status_service.task_statuses[:share_preview_status]).to eq :cannot_start
          end
        end

        context "when the form has pages" do
          let(:form) { build(:form, :with_pages, share_preview_completed: true) }

          it "returns completed" do
            expect(task_status_service.task_statuses[:share_preview_status]).to eq :completed
          end
        end
      end
    end

    describe "make live status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form) }

        it "returns the correct default value" do
          expect(task_status_service.task_statuses[:make_live_status]).to eq :cannot_start
        end
      end

      context "with a form which is ready to go live" do
        let(:form) { build(:form, :ready_for_live) }

        it "returns the not started status" do
          expect(task_status_service.task_statuses[:make_live_status]).to eq :not_started
        end
      end

      context "with a live form with a draft and all tasks complete" do
        let(:form) { build(:form, :ready_for_live, state: :live_with_draft) }

        it "returns the not started status" do
          expect(task_status_service.task_statuses[:make_live_status]).to eq :not_started
        end
      end

      context "with an archived form with a draft and incomplete tasks" do
        let(:form) { build(:form, state: :archived_with_draft) }

        it "returns the not started status" do
          expect(task_status_service.task_statuses[:make_live_status]).to eq :cannot_start
        end
      end

      context "with an archived form with a draft and all tasks complete" do
        let(:form) { build(:form, :ready_for_live, state: :archived_with_draft) }

        it "returns the not started status" do
          expect(task_status_service.task_statuses[:make_live_status]).to eq :not_started
        end
      end

      context "with a live form" do
        let(:form) { create(:form, :live) }

        it "returns the completed status" do
          expect(task_status_service.task_statuses[:make_live_status]).to eq :completed
        end
      end

      context "with an archived form" do
        let(:form) { build(:form, state: :archived) }

        it "returns the completed status" do
          expect(task_status_service.task_statuses[:make_live_status]).to eq :not_started
        end
      end
    end
  end

  describe "#mandatory_tasks_completed" do
    context "when mandatory tasks have not been completed" do
      let(:form) { build(:form, :new_form) }

      it "returns false" do
        expect(task_status_service.mandatory_tasks_completed?).to be false
      end
    end

    context "when mandatory tasks have been completed" do
      let(:form) { build(:form, :ready_for_live) }

      it "returns true" do
        expect(task_status_service.mandatory_tasks_completed?).to be true
      end
    end
  end

  describe "#incomplete_tasks" do
    context "when mandatory tasks are complete" do
      let(:form) { build(:form, :live) }

      it "returns no missing sections" do
        expect(task_status_service.incomplete_tasks).to be_empty
      end
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:form) { build(:form, :new_form) }

      it "returns a set of keys related to missing fields" do
        expect(task_status_service.incomplete_tasks).to match_array(%i[missing_pages missing_privacy_policy_url missing_contact_details missing_what_happens_next share_preview_not_completed])
      end
    end
  end

  describe "#task_statuses" do
    let(:form) { create(:form, :live) }

    it "returns a hash with each of the task statuses" do
      expected_hash = {
        name_status: :completed,
        pages_status: :completed,
        declaration_status: :completed,
        what_happens_next_status: :completed,
        payment_link_status: :optional,
        privacy_policy_status: :completed,
        support_contact_details_status: :completed,
        make_live_status: :completed,
        receive_csv_status: :optional,
        share_preview_status: :completed,
      }
      expect(task_status_service.task_statuses).to eq expected_hash
    end
  end
end
