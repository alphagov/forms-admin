require "rails_helper"

describe FormTaskListService do
  let(:current_user) { build(:editor_user) }

  describe ".task_counts" do
    let(:statuses) { OpenStruct.new(attributes: { declaration_status: "completed", make_live_status: "not_started", name_status: "completed", pages_status: "completed", privacy_policy_status: "not_started", support_contact_details_status: "not_started", what_happens_next_status: "completed" }) }
    let(:form) { build(:form, task_statuses: statuses) }
    let(:email_task_status_service) { instance_double(EmailTaskStatusService) }

    before do
      allow(EmailTaskStatusService).to receive(:new).and_return(email_task_status_service)
      allow(email_task_status_service).to receive(:email_task_statuses).and_return({
        submission_email_status: :completed,
        confirm_submission_email_status: :not_started,
      })
    end

    context "when the user has the editor role" do
      it "returns counts of tasks" do
        result = described_class.new(form:, current_user:)

        expected_hash = { completed: 5, total: 9 }
        expect(EmailTaskStatusService).to have_received(:new)
        expect(result.task_counts).to eq expected_hash
      end
    end

    context "when the user has the trial role" do
      let(:current_user) { build :user, :with_trial_role }

      it "returns all statuses except for those inaccessible for trial users" do
        result = described_class.new(form:, current_user:)

        expected_hash = { completed: 4, total: 6 }
        expect(EmailTaskStatusService).to have_received(:new)

        expect(result.task_counts).to eq expected_hash
      end
    end
  end

  describe "#all_sections" do
    let(:form) { build(:form, :new_form, id: 1) }

    let(:all_sections) { described_class.call(form:, current_user:).all_sections }

    it "returns array of tasks objects for a given form" do
      expect(all_sections).to be_an_instance_of(Array)
    end

    it "returns 4 sections" do
      expected_sections = [{ title: "Task 1" }, { title: "Task 2" }, { title: "Task 3" }, { title: "Task 4" }]
      expect(all_sections.count).to eq expected_sections.count
    end

    describe "section 1 tasks" do
      let(:section) do
        all_sections.first
      end

      let(:section_rows) { section[:rows] }

      it "has links to edit form name" do
        expect(section_rows.first[:task_name]).to eq "Edit the name of your form"
        expect(section_rows.first[:path]).to eq "/forms/1/change-name"
      end

      it "has a link to add new pages/questions (if no pages/questions exist)" do
        expect(section_rows[1][:task_name]).to eq "Add and edit your questions"
        expect(section_rows[1][:path]).to eq "/forms/1/pages/new/start-new-question"
      end

      it "has a link to add/edit existing pages (if pages/questions exist)" do
        page = build :page
        form.pages = [page]
        expect(section_rows[1][:task_name]).to eq "Add and edit your questions"
        expect(section_rows[1][:path]).to eq "/forms/1/pages"
      end

      it "has a link to add/edit declaration" do
        expect(section_rows[2][:task_name]).to eq "Add a declaration for people to agree to"
        expect(section_rows[2][:path]).to eq "/forms/1/declaration"
      end

      it "has a link to add/edit 'What happens next'" do
        expect(section_rows[3][:task_name]).to eq "Add information about what happens next"
        expect(section_rows[3][:path]).to eq "/forms/1/what-happens-next"
      end

      it "has the correct default statuses" do
        expect(section_rows.first[:status]).to eq :completed
        expect(section_rows[1][:status]).to eq :not_started
        expect(section_rows[2][:status]).to eq :not_started
        expect(section_rows[3][:status]).to eq :not_started
      end
    end

    describe "section 2 tasks" do
      let(:section) do
        all_sections[1]
      end

      let(:section_rows) { section[:rows] }

      context "when submission_email is set" do
        before do
          form.submission_email = "test@example.gov.uk"
        end

        it "has link to set submission email" do
          expect(section_rows.first[:task_name]).to eq "Set the email address completed forms will be sent to"
          expect(section_rows.first[:path]).to eq "/forms/1/submission-email"
        end

        it "has link to confirm submission email" do
          expect(section_rows[1][:task_name]).to eq "Enter the email address confirmation code"
          expect(section_rows[1][:path]).to eq "/forms/1/confirm-submission-email"
        end

        it "has hint text explaining where completed forms will be sent to" do
          expect(section_rows.first[:hint_text]).to eq I18n.t("forms.task_list_create.section_2.hint_text_html", submission_email: form.submission_email)
        end

        it "has the correct default status" do
          expect(section_rows.first[:status]).to eq :completed
        end
      end

      context "when submission_email is not set" do
        it "has no hint text explaining where completed forms will be sent to" do
          expect(section_rows.first[:hint_text]).to be_nil
        end

        it "has the correct default status" do
          expect(section_rows.first[:status]).to eq :not_started
        end
      end

      context "and submission_email is set and no code sent" do
        before do
          form.submission_email = "test@example.gov.uk"
        end

        it "enter email has status of completed" do
          expect(section_rows.first[:status]).to eq :completed
        end

        it "enter code has status of completed" do
          expect(section_rows[1][:status]).to eq :completed
        end
      end

      context "and submission_email is not set and no code sent" do
        it "enter email has status of not_started" do
          expect(section_rows.first[:status]).to eq :not_started
        end

        it "enter code has status of cannot_start" do
          expect(section_rows[1][:status]).to eq :cannot_start
        end

        it "enter code is not active" do
          expect(section_rows[1][:active]).to be_falsy
        end
      end

      context "and submission_email is not set and code sent" do
        before do
          create :form_submission_email, form_id: form.id, confirmation_code: form.id
        end

        it "enter email has status of in_progress" do
          expect(section_rows.first[:status]).to eq :in_progress
        end

        it "enter code has status of incomplete" do
          expect(section_rows[1][:status]).to eq :not_started
        end

        it "enter code is active" do
          expect(section_rows[1][:active]).to be_truthy
        end
      end

      context "and submission_email is set and code blank" do
        before do
          form.submission_email = "test@example.gov.uk"
          create :form_submission_email, form_id: form.id, confirmation_code: nil
        end

        it "enter email has status of completed" do
          expect(section_rows.first[:status]).to eq :completed
        end

        it "enter code has status of completed" do
          expect(section_rows[1][:status]).to eq :completed
        end
      end

      context "when current user has a trial account" do
        let(:current_user) { build :user, role: :trial }

        before do
          form.submission_email = current_user.email
        end

        it "has no tasks" do
          expect(section).not_to include(:rows)
        end

        it "has text explaining where completed forms will be sent to" do
          expect(section[:body_text])
            .to eq I18n.t(
              "forms.task_list_create.section_2.if_not_permitted.body_text",
              submission_email: form.submission_email,
            )
        end
      end
    end

    describe "section 3 tasks" do
      let(:section) do
        all_sections[2]
      end

      let(:section_rows) { section[:rows] }

      it "has link to set privacy policy url" do
        expect(section_rows.first[:task_name]).to eq "Provide a link to privacy information for this form"
        expect(section_rows.first[:path]).to eq "/forms/1/privacy-policy"
      end

      it "has link to set contact details url" do
        expect(section_rows[1][:task_name]).to eq "Provide contact details for support"
        expect(section_rows[1][:path]).to eq "/forms/1/contact-details"
      end

      it "has the correct default statuses" do
        expect(section_rows.first[:status]).to eq :not_started
        expect(section_rows[1][:status]).to eq :not_started
      end
    end

    describe "section 4 tasks" do
      let(:section) do
        all_sections[3]
      end

      let(:section_rows) { section[:rows] }

      it "has text to make the form live (no link)" do
        expect(section_rows.first[:task_name]).to eq "Make your form live"
        expect(section_rows.first[:path]).to be_empty
      end

      it "has the correct default status" do
        expect(section_rows.first[:status]).to eq :cannot_start
      end

      context "when form is ready to make live" do
        let(:form) { build(:form, :ready_for_live, id: 1) }

        it "has link to make the form live" do
          expect(section_rows.first[:task_name]).to eq "Make your form live"
          expect(section_rows.first[:path]).to eq "/forms/1/make-live"
        end

        it "has the correct default status" do
          expect(section_rows.first[:status]).to eq :not_started
        end
      end

      context "when form is live" do
        before do
          allow(form).to receive(:has_live_version).and_return(true)
        end

        it "has tasks" do
          expect(section_rows).not_to be_empty
        end

        it "describes the section title correctly" do
          expect(section[:title]).to eq I18n.t("forms.task_list_edit.section_4.make_live")
        end

        it "describes the task correctly" do
          expect(section_rows.first[:task_name]).to eq I18n.t("forms.task_list_edit.section_4.make_live")
        end
      end

      context "when current user has a trial account" do
        let(:current_user) { build :user, :with_trial_role }

        it "has no tasks" do
          expect(section).not_to include(:rows)
        end

        it "has text explaining that trial users cannot make forms live" do
          expect(section[:body_text])
            .to eq I18n.t(
              "forms.task_list_create.section_4.if_not_permitted.body_text",
            )
        end
      end
    end
  end
end
