require "rails_helper"

describe FormTaskListService do
  describe "#all_tasks" do
    let(:form) { build(:form, id: 1) }

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
        expect(section_rows[1][:path]).to eq "/forms/1/pages/new"
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
    end

    describe "section 2 tasks" do
      let(:section) do
        described_class.call(form:).all_tasks[1]
      end

      let(:section_rows) { section[:rows] }

      context "when submission_email_confirmation flag is true", feature_submission_email_confirmation: true do
        it "has link to set submission email" do
          expect(section_rows.first[:task_name]).to eq "Set the email address completed forms will be sent to"
          expect(section_rows.first[:path]).to eq "/forms/1/submission-email"
        end

        it "has link to confirm submission email" do
          expect(section_rows[1][:task_name]).to eq "Enter the email address confirmation code"
          expect(section_rows[1][:path]).to eq "/forms/1/confirm-submission-email"
        end
      end

      context "when submission_email_confirmation flag is false", feature_submission_email_confirmation: false do
        it "has link to set submission email" do
          expect(section_rows.first[:task_name]).to eq "Set the email address completed forms will be sent to"
          expect(section_rows.first[:path]).to eq "/forms/1/change-email"
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

      describe "when form is ready to make live" do
        let(:section) do
          allow(form).to receive(:ready_for_live?).and_return(true)
          described_class.call(form:).all_tasks[3]
        end

        let(:section_rows) { section[:rows] }

        it "has link to make the form live" do
          expect(section_rows.first[:task_name]).to eq "Make your form live"
          expect(section_rows.first[:path]).to eq "/forms/1/make-live"
        end
      end

      describe "when form is live" do
        let(:section) do
          allow(form).to receive(:live?).and_return(true)
          described_class.call(form:).all_tasks[3]
        end

        let(:section_rows) { section[:rows] }

        it "has no tasks" do
          expect(section_rows).to be_empty
        end
      end
    end
  end
end
