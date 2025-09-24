require "rails_helper"

describe PageRepository do
  let(:form_id) { form.id }
  let(:form) { create(:form_record) }

  describe "#find" do
    let(:page) { create(:page_record, form:) }

    it "returns the page" do
      expect(described_class.find(page_id: page.id, form_id:)).to eq(page)
    end

    context "when given a form_id that the page doesn't belong to" do
      let(:form_id) { "non-existent-id" }

      it "raises a RecordNotFound error" do
        expect {
          described_class.find(page_id: page.id, form_id:)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#create!" do
    let(:page_params) do
      { question_text: "asdf",
        hint_text: "",
        is_optional: false,
        is_repeatable: false,
        form_id:,
        answer_settings:,
        page_heading: nil,
        guidance_markdown: nil,
        answer_type: }
    end
    let(:answer_type) { "organisation_name" }
    let(:answer_settings) { {} }

    it "saves the new page to the database" do
      expect {
        described_class.create!(**page_params)
      }.to change(Page, :count).by(1)
    end

    it "returns a page record" do
      expect(described_class.create!(**page_params)).to be_a(Page)
    end

    it "associates the page with a form" do
      described_class.create!(**page_params)
      expect(Page.last).to have_attributes(form_id:)
    end

    context "when the form question section is complete" do
      let(:form) { create(:form_record, question_section_completed: true) }

      it "updates the form to mark the question section as incomplete" do
        expect {
          described_class.create!(**page_params)
        }.to change { Form.find(form_id).question_section_completed }.to(false)
      end
    end

    context "when the page has answer settings" do
      let(:answer_type) { "selection" }
      let(:answer_settings) { { only_one_option: "true", selection_options: [] } }

      it "saves the answer settings to the database" do
        described_class.create!(**page_params)
        expect(Page.last).to have_attributes(
          "answer_settings" => DataStruct.new({
            "only_one_option" => "true",
            "selection_options" => [],
          }),
        )
      end
    end
  end

  describe "#save!" do
    let(:page) { create(:page_record, form:, is_optional: false, question_text: "database page") }

    it "saves the page to the database" do
      page.is_optional = true

      expect {
        described_class.save!(page)
      }.to change { Page.find(page.id).is_optional }.to(true)
    end

    it "returns the database page" do
      expect(described_class.save!(page)).to eq(page)
    end

    context "when there are no changes to save" do
      let(:form) { create(:form_record, question_section_completed: true) }
      let(:page) { create(:page_record, form: form, answer_type: "number", answer_settings: { foo: "bar" }) }
      let(:updated_page_resource) do
        build(:page_resource,
              id: page.id,
              form_id:,
              question_text: page.question_text,
              answer_type: page.answer_type,
              answer_settings: page.answer_settings,
              position: page.position)
      end

      it "does not update the form" do
        expect {
          described_class.save!(page)
        }.not_to(change { Form.find(form_id).question_section_completed })
      end
    end

    context "when there are changes to save" do
      let(:form) { create(:form_record, question_section_completed: true) }

      it "updates the form" do
        page.is_optional = true

        expect {
          described_class.save!(page)
        }.to change { Form.find(form_id).question_section_completed }.to(false)
      end
    end
  end

  describe "#destroy" do
    let!(:page) { create(:page_record, form_id:) }

    it "removes the page from the database" do
      expect {
        described_class.destroy(page)
      }.to change(Page, :count).by(-1)
    end

    it "returns a page record" do
      expect(described_class.destroy(page)).to be_a(Page)
    end

    context "when the form question section is complete" do
      let(:form) { create(:form_record, question_section_completed: true) }

      it "updates the form to mark the question section as incomplete" do
        expect {
          described_class.destroy(page)
        }.to change { Form.find(form_id).question_section_completed }.to(false)
      end
    end

    context "when the page has routing conditions" do
      before do
        create(:condition_record, routing_page_id: page.id, check_page_id: page.id, goto_page_id: nil, skip_to_end: true, answer_value: "Red")
        create(:condition_record, routing_page_id: page.id, check_page_id: page.id, goto_page_id: nil, skip_to_end: true, answer_value: "Green")
        page.reload
      end

      it "deletes the conditions" do
        expect {
          described_class.destroy(page)
        }.to change(Condition, :count).by(-2)
      end
    end

    it "returns the deleted page" do
      expect(described_class.destroy(page)).to eq page
    end

    context "when the page has already been deleted" do
      it "returns the deleted page" do
        described_class.destroy(page)

        expect(described_class.destroy(page)).to eq page
      end
    end
  end

  describe "#move_page" do
    let(:form) { create(:form_record, :with_pages) }
    let(:page) { form.pages.second }

    it "updates the page in the database" do
      expect {
        described_class.move_page(page, :up)
      }.to change { Page.find(page.id).position }.from(2).to(1)
    end

    it "returns a page record" do
      expect(described_class.move_page(page, :up)).to be_a(Page)
    end
  end
end
