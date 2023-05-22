require "rails_helper"

describe FormTaskListService do
  describe ".task_counts" do
    let(:form) { build(:form) }
    let(:task_status_service) { instance_double(TaskStatusService) }

    before do
      allow(task_status_service).to receive(:status_counts).and_return(1234)
      allow(TaskStatusService).to receive(:new).and_return(task_status_service)
    end

    it "returns counts from task status service" do
      result = described_class.new(form:)
      expect(TaskStatusService).to have_received(:new)
      expect(result.task_counts).to eq 1234
    end
  end

  describe "#all_tasks" do
    let(:form) { build(:form, :new_form, id: 1) }

    it "returns array of tasks objects for a given form" do
      expect(described_class.call(form:).all_tasks).to be_an_instance_of(Array)
    end

    it "returns 4 sections" do
      expected_sections = [{ title: "Task 1" }, { title: "Task 2" }, { title: "Task 3" }, { title: "Task 4" }]
      expect(described_class.call(form:).all_tasks.count).to eq expected_sections.count
    end

    describe "section 1 tasks" do
      let(:section) do
        described_class.call(form:).all_tasks.first
      end

      let(:section_rows) { section[:rows] }

      it "has links to edit form name" do
        expect(section_rows.first[:task_name]).to eq "Edit the name of your form"
        expect(section_rows.first[:path]).to eq "/forms/1/change-name"
      end

      it "has a link to add new pages/questions (if no pages/questions exist)" do
        expect(section_rows[1][:task_name]).to eq "Add and edit your questions"
        expect(section_rows[1][:path]).to eq "/forms/1/pages/new/type-of-answer"
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
        described_class.call(form:).all_tasks[1]
      end

      let(:section_rows) { section[:rows] }

      context "when submission_email is set" do
        let(:section) do
          form.submission_email = "test@example.gov.uk"
          described_class.call(form:).all_tasks[1]
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
    end

    describe "section 3 tasks" do
      let(:section) do
        described_class.call(form:).all_tasks[2]
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
        described_class.call(form:).all_tasks[3]
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
        let(:section) do
          described_class.call(form:).all_tasks[3]
        end

        let(:section_rows) { section[:rows] }

        it "has link to make the form live" do
          expect(section_rows.first[:task_name]).to eq "Make your form live"
          expect(section_rows.first[:path]).to eq "/forms/1/make-live"
        end

        it "has the correct default status" do
          expect(section_rows.first[:status]).to eq :not_started
        end
      end

      context "when form is live" do
        let(:section) do
          allow(form).to receive(:has_live_version).and_return(true)
          described_class.call(form:).all_tasks[3]
        end

        let(:section_rows) { section[:rows] }

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
    end
  end
end
