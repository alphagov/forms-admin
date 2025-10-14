require "rails_helper"

describe FormCopyService do
  subject(:form_service) do
    described_class.new(form)
  end

  let(:form) { create(:form, :ready_for_live, pages_count: 2) }
  let(:group) { create(:group) }

  before do
    form.group_form = GroupForm.new(group_id: group.id, form_id: form.id)

    # live version with a routing condition
    form.pages.first.routing_conditions.create!(
      answer_value: "Yes",
      goto_page_id: form.pages.last.id,
      routing_page_id: form.pages.first.id,
    )
    FormDocument.create!(form:, tag: "live", content: form.as_form_document(live_at: form.updated_at))
    form.update!(state: :live_with_draft)
  end

  describe "#copy" do
    let(:copied_form) { form_service.copy }

    it "creates a new form with the same attributes as the original" do
      expect(copied_form.name).to eq(form.name)
      expect(copied_form.state).to eq("draft")
      expect(copied_form.pages.count).to be > 0
      expect(copied_form.pages.count).to eq(form.pages.count)
      expect(copied_form.external_id).not_to be_nil
      expect(copied_form.external_id).not_to be_empty
      expect(copied_form.external_id).not_to eq(form.external_id)
    end

    it "copies the group the form belongs to" do
      expect(copied_form.group).to eq(group)
    end

    it "does not copy over the id or timestamps" do
      expect(copied_form.id).not_to eq(form.id)
      expect(copied_form.created_at).not_to eq(form.created_at)
      expect(copied_form.updated_at).not_to eq(form.updated_at)
    end

    it "copies over associated pages and routing_conditions" do
      form.pages.each_with_index do |page, index|
        copied_page = copied_form.pages[index]
        expect(copied_page.page_heading).to eq(page.page_heading)
        expect(copied_page.routing_conditions.count).to eq(page.routing_conditions.count)

        copied_page.routing_conditions.each do |condition|
          if condition.answer_value.present?
            expect(condition.answer_value).to eq("Yes")
          end
          if condition.goto_page_id.present?
            expect(copied_form.pages.pluck(:id)).to include(condition.goto_page_id)
          end
        end
      end
    end

    it "copies over conditions" do
      form.pages.each_with_index do |page, index|
        copied_page = copied_form.pages[index]
        expect(copied_page.routing_conditions.count).to eq(page.routing_conditions.count)
      end
    end

    it "sets the state of the copied form to draft" do
      expect(copied_form.state).to eq("draft")
    end
  end
end
