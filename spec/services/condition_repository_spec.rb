require "rails_helper"

describe ConditionRepository do
  let(:form) { create(:form_record) }
  let(:routing_page) { create(:page_record, form:) }
  let(:goto_page) { create(:page_record, form:) }

  context "when use_database_as_truth is false" do
    before do
      allow(Settings).to receive(:use_database_as_truth).and_return(false)
    end

    describe "#create!" do
      let(:created_condition_id) { 4 }
      let(:condition_params) do
        { form_id: form.id,
          page_id: routing_page.id,
          check_page_id: routing_page.id,
          routing_page_id: routing_page.id,
          answer_value: "Yes",
          goto_page_id: goto_page.id,
          skip_to_end: false,
          exit_page_heading: nil,
          exit_page_markdown: nil }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions", post_headers, { id: created_condition_id }.to_json, 200
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

        it "returns a condition record" do
          expect(described_class.create!(**condition_params)).to be_a(Condition)
        end

        context "when the form question section is complete" do
          let(:form) { create(:form_record, question_section_completed: true) }

          it "updates the form to mark the question section as incomplete" do
            expect {
              described_class.create!(**condition_params)
            }.to change { Form.find(form.id).question_section_completed }.to(false)
          end
        end

        it "associates the condition with pages" do
          described_class.create!(**condition_params)
          expect(Condition.last).to have_attributes(routing_page_id: routing_page.id, check_page_id: routing_page.id, goto_page_id: goto_page.id)
        end
      end

      it "has the same ID in the database and for the API" do
        described_class.create!(**condition_params)
        expect(Condition.last.id).to eq created_condition_id
      end
    end

    describe "#find" do
      let(:condition) { build(:condition_resource, id: 4, routing_page_id: routing_page.id, check_page_id: routing_page.id, goto_page_id: goto_page.id) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions/#{condition.id}", headers, condition.to_json, 200
        end
      end

      describe "api" do
        it "finds the condition through ActiveResource" do
          described_class.find(condition_id: condition.id, form_id: form.id, page_id: routing_page.id)
          expect(Api::V1::ConditionResource.new(id: condition.id, form_id: form.id, page_id: routing_page.id)).to have_been_read
        end
      end

      describe "database" do
        it "saves the condition to the database" do
          expect {
            described_class.find(condition_id: condition.id, form_id: form.id, page_id: routing_page.id)
          }.to change(Condition, :count).by(1)
        end

        it "returns a condition record" do
          expect(described_class.find(condition_id: condition.id, form_id: form.id, page_id: routing_page.id)).to be_a(Condition)
        end

        it "associates the condition with pages" do
          described_class.find(condition_id: condition.id, form_id: form.id, page_id: routing_page.id)
          expect(Condition.last).to have_attributes(routing_page_id: routing_page.id, check_page_id: routing_page.id, goto_page_id: goto_page.id)
        end

        context "when the condition already exists in the database" do
          let!(:existing_condition) { create(:condition_record, id: condition.id, routing_page_id: routing_page.id, check_page_id: routing_page.id, goto_page_id: goto_page.id) }

          it "does not create a new condition" do
            expect {
              described_class.find(condition_id: existing_condition.id, form_id: form.id, page_id: routing_page.id)
            }.not_to change(Condition, :count)
          end

          it "returns the existing condition" do
            expect(described_class.find(condition_id: existing_condition.id, form_id: form.id, page_id: routing_page.id)).to eq(existing_condition)
          end
        end
      end
    end

    describe "#save!" do
      let(:condition) { create(:condition_record, skip_to_end: false, routing_page_id: routing_page.id, answer_value: "database answer value") }
      let(:updated_condition_resource) { build(:condition_resource, id: condition.id, routing_page_id: routing_page.id, skip_to_end: true, answer_value: "API answer value") }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions/#{condition.id}", post_headers, updated_condition_resource.to_json, 200
        end
      end

      describe "api" do
        it "updates the condition through ActiveResource" do
          condition.skip_to_end = true
          described_class.save!(condition)
          expect(Api::V1::ConditionResource.new(id: condition.id, skip_to_end: true, form_id: form.id, page_id: routing_page.id)).to have_been_updated
          expect(JSON.parse(ActiveResource::HttpMock.requests.first.body)).to include("skip_to_end" => true)
        end

        it "returns a condition constructed from the API response" do
          expect(described_class.save!(condition)).to have_attributes(answer_value: "API answer value")
        end
      end

      describe "database" do
        it "saves the condition to the repository" do
          condition.skip_to_end = true

          expect {
            described_class.save!(condition)
          }.to change { Condition.find(condition.id).skip_to_end }.to(true)
        end

        it "returns a condition record" do
          expect(described_class.save!(condition)).to be_a(Condition)
        end

        context "when the form question section is complete" do
          let(:form) { create(:form_record, question_section_completed: true) }

          it "updates the form to mark the question section as incomplete" do
            expect {
              described_class.save!(condition)
            }.to change { Form.find(form.id).question_section_completed }.to(false)
          end
        end
      end
    end

    describe "#destroy" do
      let(:condition) { create(:condition_record, routing_page_id: routing_page.id) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions/#{condition.id}", delete_headers, nil, 204
        end
      end

      describe "api" do
        it "destroys the condition through ActiveResource" do
          described_class.destroy(condition)
          expect(Api::V1::ConditionResource.new(id: condition.id, form_id: form.id, page_id: routing_page.id)).to have_been_deleted
        end

        context "when the condition has already been deleted" do
          before do
            ActiveResource::HttpMock.respond_to do |mock|
              mock.delete "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions/#{condition.id}", delete_headers, nil, 404
            end
          end

          it "does not raise an error" do
            expect {
              described_class.destroy(condition)
            }.not_to raise_error
          end

          it "still deletes the condition from the database" do
            expect {
              described_class.destroy(condition)
            }.to change(Condition, :count).by(-1)
          end
        end
      end

      describe "database" do
        it "removes the condition from the database" do
          expect {
            described_class.destroy(condition)
          }.to change(Condition, :count).by(-1)
        end

        it "returns a condition record" do
          expect(described_class.destroy(condition)).to be_a(Condition)
        end

        context "when the form question section is complete" do
          let(:form) { create(:form_record, question_section_completed: true) }

          it "updates the form to mark the question section as incomplete" do
            expect {
              described_class.destroy(condition)
            }.to change { Form.find(form.id).question_section_completed }.to(false)
          end
        end
      end

      it "returns the deleted condition" do
        expect(described_class.destroy(condition)).to eq condition
      end
    end
  end

  context "when use_database_as_truth is true" do
    before do
      allow(Settings).to receive(:use_database_as_truth).and_return(true)
    end

    describe "#create!" do
      let(:condition_params) do
        { form_id: form.id,
          page_id: routing_page.id,
          check_page_id: routing_page.id,
          routing_page_id: routing_page.id,
          answer_value: "Yes",
          goto_page_id: goto_page.id,
          skip_to_end: false,
          exit_page_heading: nil,
          exit_page_markdown: nil }
      end
      let(:ignored_api_condition_id) { 999_999 }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions", post_headers, { id: ignored_api_condition_id }.to_json, 200
        end
      end

      describe "api" do
        it "creates a condition through ActiveResource" do
          condition = described_class.create!(**condition_params)
          expect(Api::V1::ConditionResource.new(condition.attributes.merge(form_id: form.id, page_id: routing_page.id))).to have_been_created
        end
      end

      describe "database" do
        it "saves the condition to the database" do
          expect {
            described_class.create!(**condition_params)
          }.to change(Condition, :count).by(1)
        end

        it "returns a condition record" do
          expect(described_class.create!(**condition_params)).to be_a(Condition)
        end

        it "doesn't use the API response to create the condition" do
          expect(described_class.create!(**condition_params).id).not_to eq(ignored_api_condition_id)
        end

        context "when the form question section is complete" do
          let(:form) { create(:form_record, question_section_completed: true) }

          it "updates the form to mark the question section as incomplete" do
            expect {
              described_class.create!(**condition_params)
            }.to change { Form.find(form.id).question_section_completed }.to(false)
          end
        end

        it "associates the condition with pages" do
          described_class.create!(**condition_params)
          expect(Condition.last).to have_attributes(routing_page_id: routing_page.id, check_page_id: routing_page.id, goto_page_id: goto_page.id)
        end
      end

      it "has the same ID in the database and for the API" do
        described_class.create!(**condition_params)
        expect(JSON.parse(ActiveResource::HttpMock.requests.first.body)).to include("id" => Condition.last.id)
      end
    end

    describe "#find" do
      let(:condition) { create(:condition_record, routing_page_id: routing_page.id, check_page_id: routing_page.id, goto_page_id: goto_page.id) }

      it "does not call the API" do
        described_class.find(condition_id: condition.id, form_id: form.id, page_id: routing_page.id)
        expect(Api::V1::ConditionResource.new(id: condition.id, form_id: form.id, page_id: routing_page.id)).not_to have_been_read
      end

      it "returns the condition" do
        expect(described_class.find(condition_id: condition.id, form_id: form.id, page_id: routing_page.id)).to eq(condition)
      end

      context "when given a page_id that the condition doesn't belong to" do
        let(:page_id) { "non-existent-id" }

        it "raises a RecordNotFound error" do
          expect {
            described_class.find(condition_id: condition.id, form_id: form.id, page_id: page_id)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "#save!" do
      let(:condition) { create(:condition_record, skip_to_end: false, routing_page_id: routing_page.id, answer_value: "database condition") }
      let(:updated_condition_resource) { build(:condition_resource, id: condition.id, routing_page_id: routing_page.id, skip_to_end: true, answer_value: "API condition") }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions/#{condition.id}", post_headers, updated_condition_resource.to_json, 200
        end
      end

      describe "api" do
        it "updates the condition through ActiveResource" do
          condition.skip_to_end = true
          described_class.save!(condition)
          expect(Api::V1::ConditionResource.new(id: condition.id, skip_to_end: true, form_id: form.id, page_id: routing_page.id)).to have_been_updated
          expect(JSON.parse(ActiveResource::HttpMock.requests.first.body)).to include("skip_to_end" => true)
        end
      end

      describe "database" do
        it "saves the condition to the database" do
          condition.skip_to_end = true

          expect {
            described_class.save!(condition)
          }.to change { Condition.find(condition.id).skip_to_end }.to(true)
        end

        it "returns the database condition" do
          expect(described_class.save!(condition)).to eq(condition)
        end

        it "doesn't use the API response to update the condition" do
          expect(described_class.save!(condition).answer_value).to eq("database condition")
        end

        context "when the form question section is complete" do
          let(:form) { create(:form_record, question_section_completed: true) }

          it "updates the form to mark the question section as incomplete" do
            expect {
              described_class.save!(condition)
            }.to change { Form.find(form.id).question_section_completed }.to(false)
          end
        end
      end
    end

    describe "#destroy" do
      let(:condition) { create(:condition_record, routing_page_id: routing_page.id) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions/#{condition.id}", delete_headers, nil, 204
        end
      end

      describe "api" do
        it "destroys the condition through ActiveResource" do
          described_class.destroy(condition)
          expect(Api::V1::ConditionResource.new(id: condition.id, form_id: form.id, page_id: routing_page.id)).to have_been_deleted
        end

        context "when the condition has already been deleted" do
          before do
            ActiveResource::HttpMock.respond_to do |mock|
              mock.delete "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions/#{condition.id}", delete_headers, nil, 404
            end
          end

          it "does not raise an error" do
            expect {
              described_class.destroy(condition)
            }.not_to raise_error
          end

          it "still deletes the condition from the database" do
            expect {
              described_class.destroy(condition)
            }.to change(Condition, :count).by(-1)
          end
        end
      end

      describe "database" do
        it "removes the condition from the database" do
          expect {
            described_class.destroy(condition)
          }.to change(Condition, :count).by(-1)
        end

        it "returns a condition record" do
          expect(described_class.destroy(condition)).to be_a(Condition)
        end

        context "when the form question section is complete" do
          let(:form) { create(:form_record, question_section_completed: true) }

          it "updates the form to mark the question section as incomplete" do
            expect {
              described_class.destroy(condition)
            }.to change { Form.find(form.id).question_section_completed }.to(false)
          end
        end
      end

      it "returns the deleted condition" do
        expect(described_class.destroy(condition)).to eq condition
      end
    end
  end
end
