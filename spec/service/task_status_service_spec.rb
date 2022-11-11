require "rails_helper"

describe TaskStatusService do
  let(:task_status_service) do
    described_class.new(form:)
  end

  describe "statuses" do
    let(:statuses) do
      task_status_service.statuses
    end

    describe "name status" do
      let(:form) { build(:form, :new_form, id: 1) }

      it "returns the correct default value" do
        expect(statuses[:name_status]).to eq :completed
      end
    end

    describe "pages status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form, id: 1) }

        it "returns the correct default value" do
          expect(statuses[:pages_status]).to eq :incomplete
        end
      end

      context "with a form which has pages" do
        let(:form) { build(:form, :new_form, :with_pages, id: 1, question_section_completed: false) }

        it "returns the in progress status" do
          expect(statuses[:pages_status]).to eq :in_progress
        end

        context "and questions marked completed" do
          let(:form) { build(:form, :new_form, :with_pages, id: 1, question_section_completed: true) }

          it "returns the completed status" do
            expect(statuses[:pages_status]).to eq :completed
          end
        end
      end
    end

    describe "declaration status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form, id: 1) }

        it "returns the correct default value" do
          expect(statuses[:declaration_status]).to eq :incomplete
        end
      end

      context "with a form which has a declaration marked incomplete" do
        let(:form) { build(:form, id: 1, declaration_section_completed: false) }

        it "returns the incomplete status" do
          expect(statuses[:declaration_status]).to eq :incomplete
        end
      end

      context "with a form which has a declaration marked complete" do
        let(:form) { build(:form, id: 1, declaration_section_completed: true) }

        it "returns the completed status" do
          expect(statuses[:declaration_status]).to eq :completed
        end
      end
    end

    describe "what happens next status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form, id: 1) }

        it "returns the correct default value" do
          expect(statuses[:what_happens_next_status]).to eq :incomplete
        end
      end

      context "with a form which has a what happens next section" do
        let(:form) { build(:form, :new_form, id: 1, what_happens_next_text: "We usually respond to applications within 10 working days.") }

        it "returns the in progress status" do
          expect(statuses[:what_happens_next_status]).to eq :completed
        end
      end
    end

    describe "submission email status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form, id: 1) }

        it "returns the correct default value" do
          expect(statuses[:submission_email_status]).to eq :incomplete
        end
      end

      context "with a form which has an email set" do
        let(:form) { build(:form, :new_form, id: 1, submission_email: Faker::Internet.email(domain: "example.gov.uk")) }

        it "returns the in progress status" do
          expect(statuses[:submission_email_status]).to eq :completed
        end
      end
    end

    describe "privacy policy status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form, id: 1) }

        it "returns the correct default value" do
          expect(statuses[:privacy_policy_status]).to eq :incomplete
        end
      end

      context "with a form which has a privacy policy section" do
        let(:form) { build(:form, :new_form, id: 1, privacy_policy_url: Faker::Internet.url(host: "gov.uk")) }

        it "returns the in progress status" do
          expect(statuses[:privacy_policy_status]).to eq :completed
        end
      end
    end

    describe "support contact details status status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form, id: 1) }

        it "returns the correct default value" do
          expect(statuses[:support_contact_details_status]).to eq :incomplete
        end
      end

      context "with a form which has contact details set" do
        let(:form) { build(:form, :new_form, :with_support, id: 1) }

        it "returns the in progress status" do
          expect(statuses[:support_contact_details_status]).to eq :completed
        end
      end
    end

    describe "make live status" do
      context "with a new form" do
        let(:form) { build(:form, :new_form, id: 1) }

        it "returns the correct default value" do
          expect(statuses[:make_live_status]).to eq :cannot_start
        end
      end

      context "with a form which is ready to go live" do
        let(:form) { build(:form, :ready_for_live, id: 1) }

        it "returns the not started status" do
          expect(statuses[:make_live_status]).to eq :not_started
        end
      end
    end
  end

  describe "#is_complete?" do
    let(:form) { build(:form, :new_form, :with_pages, question_section_completed: false) }

    it "returns true for a complete task" do
      expect(task_status_service.is_complete?(:name_status)).to eq true
    end

    it "returns false for an in progress task" do
      expect(task_status_service.is_complete?(:pages_status)).to eq false
    end

    it "returns false for an incomplete task" do
      expect(task_status_service.is_complete?(:support_contact_details_status)).to eq false
    end
  end
end
