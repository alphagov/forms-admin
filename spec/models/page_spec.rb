require "rails_helper"

RSpec.describe Page, type: :model do
  subject(:page) { create :page_record, :with_selection_settings, form:, routing_conditions:, check_conditions: }

  let(:form) { create :form_record }
  let(:routing_conditions) { [] }
  let(:check_conditions) { [] }

  it "has a valid factory" do
    page = create :page_record
    expect(page).to be_valid
  end

  describe "associations" do
    let(:form) { create :form_record }
    let(:page) { create :page_record, form: }

    context "when it has a routing condition" do
      let!(:condition) { page.routing_conditions.create! }

      it "deletes the condition if it is deleted" do
        page.destroy!

        expect(condition).to be_destroyed
      end
    end

    context "when it has a check condition" do
      let(:routing_page) { create :page_record, form: }
      let!(:condition) { page.check_conditions.create! routing_page: }

      it "deletes the condition if it is deleted" do
        page.destroy!

        expect(condition).to be_destroyed
      end
    end

    context "when it has a go to condition" do
      let(:routing_page) { create :page_record, form: }
      let!(:condition) { page.goto_conditions.create! routing_page: }

      it "removes association from the condition if it is deleted" do
        page.destroy!

        expect(condition).to be_destroyed
        expect(condition.goto_page).to be_nil
      end

      context "and the routing page has a secondary skip condition" do
        let(:end_of_first_branch) { create :page_record, form: }
        let!(:condition) { page.goto_conditions.create! routing_page:, check_page: routing_page }
        let!(:secondary_skip_condition) { routing_page.check_conditions.create! routing_page: end_of_first_branch, skip_to_end: true }

        it "deletes the secondary skip condition if it is deleted" do
          expect {
            page.destroy!
          }.to change(Condition, :count).by(-2)

          expect(condition).to be_destroyed
          expect(Condition).not_to exist(secondary_skip_condition.id)
        end
      end

      context "and the routing page has other routing conditions" do
        let!(:condition) { page.goto_conditions.create! routing_page:, check_page: routing_page }
        let!(:other_condition) { routing_page.routing_conditions.create! routing_page:, check_page: routing_page, skip_to_end: true }

        it "does not deletes the other conditions if it is deleted" do
          expect {
            page.destroy!
          }.to change(Condition, :count).by(-1)

          expect(condition).to be_destroyed
          expect(Condition).to exist(other_condition.id)
        end
      end
    end

    context "when the form has a branching route with skip and secondary skip" do
      let(:branch_question) { create :page_record, form: }
      let(:end_of_first_branch) { create :page_record, form: }
      let(:start_of_second_branch) { create :page_record, form: }
      let(:end_of_branches) { create :page_record, form: }

      let!(:skip_condition) do
        create :condition_record, routing_page: branch_question, check_page: branch_question, goto_page: start_of_second_branch
      end
      let!(:secondary_skip_condition) do
        create :condition_record, routing_page: end_of_first_branch, check_page: branch_question, goto_page: end_of_branches
      end

      before do
        branch_question.reload
        end_of_first_branch.reload
        start_of_second_branch.reload
        end_of_branches.reload
      end

      context "and the branch question has been deleted" do
        it "deletes all the conditions" do
          expect {
            branch_question.destroy!
          }.to change(Condition, :count).from(2).to(0)

          expect(Condition).not_to exist(skip_condition.id)
          expect(Condition).not_to exist(secondary_skip_condition.id)
        end
      end

      context "and the question at the start of the second branch has been deleted" do
        it "deletes all the conditions" do
          expect {
            start_of_second_branch.destroy!
          }.to change(Condition, :count).from(2).to(0)

          expect(Condition).not_to exist(skip_condition.id)
          expect(Condition).not_to exist(secondary_skip_condition.id)
        end
      end

      context "and the question at the end of the branches has been deleted" do
        it "deletes the secondary skip condition" do
          expect {
            end_of_branches.destroy!
          }.to change(Condition, :count).from(2).to(1)

          expect(Condition).to exist(skip_condition.id)
          expect(Condition).not_to exist(secondary_skip_condition.id)
        end
      end

      context "and the question at the end of the first branch has been deleted" do
        it "deletes the secondary skip condition" do
          expect {
            end_of_first_branch.destroy!
          }.to change(Condition, :count).from(2).to(1)

          expect(Condition).to exist(skip_condition.id)
          expect(Condition).not_to exist(secondary_skip_condition.id)
        end
      end
    end
  end

  describe "validations" do
    it "validates" do
      page.question_text = "Example question"
      page.answer_type = "national_insurance_number"
      expect(page).to be_valid
    end

    describe "#question_text" do
      let(:page) { build :page_record, question_text: }
      let(:question_text) { "What is your address?" }

      it "is required" do
        page.question_text = nil
        expect(page).to be_invalid
        expect(page.errors[:question_text]).to include("Enter a question")
      end

      it "is valid if question text below 250 characters" do
        expect(page).to be_valid
      end

      context "when question text 250 characters" do
        let(:question_text) { "A" * 250 }

        it "is valid" do
          expect(page).to be_valid
        end
      end

      context "when question text more 250 characters" do
        let(:question_text) { "A" * 251 }

        it "is invalid" do
          expect(page).not_to be_valid
        end

        it "has an error message" do
          page.valid?
          expect(page.errors[:question_text]).to include("Question text must be 250 characters or less")
        end
      end
    end

    describe "#hint_text" do
      let(:page) { build :page_record, hint_text: }
      let(:hint_text) { "Enter your full name as it appears in your passport" }

      it "is valid if hint text is empty" do
        page.hint_text = nil
        expect(page).to be_valid
      end

      it "is valid if hint text below 500 characters" do
        expect(page).to be_valid
      end

      context "when hint text 500 characters" do
        let(:hint_text) { "A" * 500 }

        it "is valid" do
          expect(page).to be_valid
        end
      end

      context "when hint text more than 500 characters" do
        let(:hint_text) { "A" * 501 }

        it "is invalid" do
          expect(page).not_to be_valid
        end

        it "has an error message" do
          page.valid?
          expect(page.errors[:hint_text]).to include("Hint text must be 500 characters or less")
        end
      end
    end

    it "requires form" do
      page.form_id = nil
      expect(page).to be_invalid
      expect(page.errors[:form]).to include("must exist")
    end

    it "requires answer_type" do
      page.answer_type = nil
      expect(page).to be_invalid
      expect(page.errors[:answer_type]).to include("can't be blank")
    end

    it "requires answer_type to be in list" do
      page.answer_type = "unknown_type"
      expect(page).to be_invalid
      expect(page.errors[:answer_type]).to include("is not included in the list")
    end

    context "when guidance_fields are provided" do
      it "requires guidance_markdown if page_heading is present" do
        page.page_heading = "My new page heading"
        expect(page).to be_invalid
        expect(page.errors[:guidance_markdown]).to include("must be present when Page Heading is present")
      end

      it "requires page_heading if guidance_markdown is present" do
        page.guidance_markdown = "Some extra guidance for this question"
        expect(page).to be_invalid
        expect(page.errors[:page_heading]).to include("must be present when Guidance Markdown is present")
      end

      describe "page_heading length validations" do
        let(:page) { build :page_record, :with_guidance, page_heading: }
        let(:page_heading) { "What is your address?" }

        it "is valid if page heading below 500 characters" do
          expect(page).to be_valid
        end

        context "when page heading 250 characters" do
          let(:page_heading) { "A" * 250 }

          it "is valid" do
            expect(page).to be_valid
          end
        end

        context "when page_heading more than 250 characters" do
          let(:page_heading) { "A" * 251 }

          it "is invalid" do
            expect(page).not_to be_valid
          end

          it "has an error message" do
            page.valid?
            expect(page.errors[:page_heading]).to include("Page heading must be 250 characters or less")
          end
        end
      end

      context "when markdown is too long" do
        it "adds an error to guidance_markdown" do
          page.guidance_markdown = "ABC" * 5000
          expect(page).to be_invalid
          expect(page.errors[:guidance_markdown]).to include("is too long (maximum is 4999 characters)")
        end
      end

      context "when markdown is using unsupported syntax" do
        it "adds error to guidance_markdown" do
          page.guidance_markdown = "# Heading level 1"
          expect(page).to be_invalid
          expect(page.errors[:guidance_markdown]).to include("can only contain formatting for links, subheadings(##), bulleted listed (*), or numbered lists(1.)")
        end
      end

      context "when markdown is using unsupported syntax which is too long" do
        it "adds error to guidance_markdown" do
          page.guidance_markdown = "# Heading level 1\n\n" * 5000
          expect(page).to be_invalid
          expect(page.errors[:guidance_markdown]).to include("can only contain formatting for links, subheadings(##), bulleted listed (*), or numbered lists(1.)")
          expect(page.errors[:guidance_markdown]).to include("is too long (maximum is 4999 characters)")
        end
      end
    end
  end

  describe "#destroy_and_update_form!" do
    let(:page) { create :page_record }
    let(:form) { page.form }

    it "sets form.question_section_completed to false" do
      form.update!(question_section_completed: true)

      page.destroy_and_update_form!
      expect(form.question_section_completed).to be false
    end
  end

  describe "#save_and_update_form" do
    it "sets form.question_section_completed to false" do
      page.question_text = "Edited question"
      page.save_and_update_form
      expect(form.question_section_completed).to be false
    end

    context "when the form is live" do
      let(:form) { create(:form_record, :live) }

      it "updates the form state to live_with_draft" do
        page.question_text = "Edited question"
        page.save_and_update_form
        expect(form.state).to eq("live_with_draft")
      end
    end

    context "when the form is archived" do
      let(:form) { create(:form_record, :archived) }

      it "updates the form state to archived_with_draft" do
        page.question_text = "Edited question"
        page.save_and_update_form
        expect(form.state).to eq("archived_with_draft")
      end
    end

    context "when page has routing conditions" do
      let(:routing_conditions) { [(create :condition_record)] }
      let(:check_conditions) { routing_conditions }

      it "does not delete existing conditions" do
        page.save_and_update_form
        expect(page.reload.routing_conditions.to_a).to eq(routing_conditions)
        expect(page.reload.check_conditions.to_a).to eq(check_conditions)
      end

      context "when answer type is updated to one doesn't support routing" do
        it "deletes any conditions" do
          page.answer_type = "number"
          page.save_and_update_form
          expect(page.reload.check_conditions).to be_empty
        end
      end

      context "when the page is saved without changing the answer type" do
        it "does not delete the conditions" do
          page.question_text = "test"
          page.save_and_update_form
          expect(page.reload.check_conditions).not_to be_empty
        end
      end

      context "when the answer settings no longer restrict to only one option" do
        it "deletes any conditions" do
          page.answer_settings["only_one_option"] = "0"
          page.save_and_update_form
          expect(page.reload.check_conditions).to be_empty
        end
      end

      context "when the answer settings change while still restricting to only one option" do
        it "does not delete any conditions" do
          page.answer_settings["selection_options"].first["name"] = "New option name"
          page.save_and_update_form
          expect(page.reload.check_conditions).not_to be_empty
        end
      end
    end
  end

  describe "#has_routing_errors" do
    subject(:page) { build :page_record, :with_selection_settings, routing_conditions: [condition] }

    let(:condition) { build :condition_record }
    let(:has_routing_errors) { false }

    before do
      allow(condition).to receive(:has_routing_errors).and_return(has_routing_errors)
    end

    context "when there are no validation errors" do
      it "returns false" do
        expect(page.has_routing_errors).to be false
      end
    end

    context "when there are validation errors" do
      let(:has_routing_errors) { true }

      it "returns true" do
        expect(page.has_routing_errors).to be true
      end
    end
  end
end
