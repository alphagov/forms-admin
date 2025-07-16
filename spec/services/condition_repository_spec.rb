require "rails_helper"

describe ConditionRepository do
  let(:form_id) { form.id }
  let(:form_attributes) { attributes_for(:form) }
  let(:form) do
    form = build(:form_resource, **form_attributes)
    form.id = Form.create!(form.database_attributes).id
    form
  end

  let(:routing_page_id) { routing_page.id }
  let(:routing_page) do
    page = build(:page_resource, form_id:)
    page.id = Page.create!(page.database_attributes).id
    page
  end

  describe "#create!" do
    let(:condition_params) do
      { form_id:,
        page_id: routing_page_id,
        check_page_id: routing_page_id,
        routing_page_id:,
        answer_value: "Yes",
        goto_page_id: 3,
        skip_to_end: false,
        exit_page_heading: nil,
        exit_page_markdown: nil }
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms/#{form_id}/pages/#{routing_page_id}/conditions", post_headers, { id: 4 }.to_json, 200
      end
    end

    describe "api" do
      it "creates a condition through ActiveResource" do
        described_class.create!(**condition_params)
        expect(Api::V1::ConditionResource.new(**condition_params)).to have_been_created
      end
    end

    describe "database" do
      it "saves the condition to the database" do
        expect {
          described_class.create!(**condition_params)
        }.to change(Condition, :count).by(1)
      end

      context "when the form question section is complete" do
        let(:form_attributes) { attributes_for(:form, question_section_completed: true) }

        it "updates the form to mark the question section as incomplete" do
          expect {
            described_class.create!(**condition_params)
          }.to change { Form.find(form_id).question_section_completed }.to(false)
        end
      end

      it "associates the condition with pages" do
        described_class.create!(**condition_params)
        expect(Condition.last).to have_attributes(routing_page_id:, check_page_id: routing_page_id, goto_page_id: 3)
      end
    end

    it "has the same ID in the database and for the API" do
      condition = described_class.create!(**condition_params)
      expect(Condition.last.id).to eq condition.id
    end
  end

  describe "#find" do
    let(:condition) { build(:condition_resource, id: 4, form_id: form_id, page_id: routing_page_id, routing_page_id:, check_page_id: routing_page_id, goto_page_id: 3) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/#{form_id}/pages/#{routing_page_id}/conditions/#{condition.id}", headers, condition.to_json, 200
      end
    end

    describe "api" do
      it "finds the condition through ActiveResource" do
        described_class.find(condition_id: condition.id, form_id:, page_id: routing_page_id)
        expect(Api::V1::ConditionResource.new(id: 4, form_id:, page_id: routing_page_id)).to have_been_read
      end
    end

    describe "database" do
      it "saves the condition to the database" do
        expect {
          described_class.find(condition_id: condition.id, form_id:, page_id: routing_page_id)
        }.to change(Condition, :count).by(1)
      end

      it "associates the condition with pages" do
        described_class.find(condition_id: condition.id, form_id:, page_id: routing_page_id)
        expect(Condition.last).to have_attributes(routing_page_id:, check_page_id: routing_page_id, goto_page_id: 3)
      end
    end
  end

  describe "#save!" do
    let(:condition) { build(:condition_resource, id: 4, skip_to_end: false, form_id:, page_id: routing_page_id, routing_page_id:) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/#{form_id}/pages/#{routing_page_id}/conditions/4", headers, condition.to_json, 200
        mock.put "/api/v1/forms/#{form_id}/pages/#{routing_page_id}/conditions/4", post_headers
      end
    end

    describe "api" do
      it "updates the condition through ActiveResource" do
        condition = described_class.find(condition_id: 4, form_id:, page_id: routing_page_id)
        condition.skip_to_end = true
        described_class.save!(condition)
        expect(Api::V1::ConditionResource.new(id: 4, skip_to_end: true, form_id:, page_id: routing_page_id)).to have_been_updated
      end
    end

    describe "database" do
      it "saves the condition to the repository" do
        condition = described_class.find(condition_id: 4, form_id:, page_id: routing_page_id)
        condition.skip_to_end = true

        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/#{form_id}/pages/#{routing_page_id}/conditions/4", put_headers, condition.to_json
        end

        expect {
          described_class.save!(condition)
        }.to change { Condition.find(4).skip_to_end }.to(true)
      end

      context "when the form question section is complete" do
        let(:form_attributes) { attributes_for(:form, question_section_completed: true) }

        it "updates the form to mark the question section as incomplete" do
          condition = described_class.find(condition_id: 4, form_id:, page_id: routing_page_id)

          expect {
            described_class.save!(condition)
          }.to change { Form.find(form_id).question_section_completed }.to(false)
        end
      end
    end
  end

  describe "#destroy" do
    let(:condition) { build(:condition_resource, id: 4, form_id:, page_id: routing_page_id, routing_page_id:) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/#{form_id}/pages/#{routing_page_id}/conditions/4", headers, condition.to_json, 200
        mock.delete "/api/v1/forms/#{form_id}/pages/#{routing_page_id}/conditions/4", delete_headers, nil, 204
      end
    end

    describe "api" do
      it "destroys the condition through ActiveResource" do
        condition = described_class.find(condition_id: 4, form_id:, page_id: routing_page_id)
        described_class.destroy(condition)
        expect(Api::V1::ConditionResource.new(id: 4, form_id:, page_id: routing_page_id)).to have_been_deleted
      end

      context "when the condition has already been deleted" do
        it "does not raise an error" do
          condition = described_class.find(condition_id: 4, form_id:, page_id: routing_page_id)
          described_class.destroy(condition)

          ActiveResource::HttpMock.respond_to do |mock|
            mock.delete "/api/v1/forms/#{form_id}/pages/#{routing_page_id}/conditions/4", delete_headers, nil, 404
          end

          expect {
            described_class.destroy(condition)
          }.not_to raise_error
        end

        it "returns the deleted condition" do
          condition = described_class.find(condition_id: 4, form_id:, page_id: routing_page_id)
          described_class.destroy(condition)

          ActiveResource::HttpMock.respond_to do |mock|
            mock.delete "/api/v1/forms/#{form_id}/pages/#{routing_page_id}/conditions/4", delete_headers, nil, 404
          end

          expect(described_class.destroy(condition)).to eq condition
        end
      end
    end

    describe "database" do
      it "removes the condition from the database" do
        condition = described_class.find(condition_id: 4, form_id:, page_id: routing_page_id)

        expect {
          described_class.destroy(condition)
        }.to change(Condition, :count).by(-1)
      end

      context "when the form question section is complete" do
        let(:form_attributes) { attributes_for(:form, question_section_completed: true) }

        it "updates the form to mark the question section as incomplete" do
          condition = described_class.find(condition_id: 4, form_id:, page_id: routing_page_id)

          expect {
            described_class.destroy(condition)
          }.to change { Form.find(form_id).question_section_completed }.to(false)
        end
      end

      context "when the condition is not already in the database" do
        it "does not raise an error" do
          condition = Api::V1::ConditionResource.new(id: 4, form_id:, page_id: routing_page_id)
          expect {
            described_class.destroy(condition)
          }.not_to raise_error
        end
      end
    end

    it "returns the deleted condition" do
      condition = described_class.find(condition_id: 4, form_id:, page_id: routing_page_id)
      expect(described_class.destroy(condition)).to eq condition
    end
  end
end
