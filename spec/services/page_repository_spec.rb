require "rails_helper"

describe PageRepository do
  let(:form_id) { form.id }
  let(:form) { create(:form_record) }

  context "when use_database_as_truth is false" do
    before do
      allow(Settings).to receive(:use_database_as_truth).and_return(false)
    end

    describe "#find" do
      let(:page) { build(:page_resource, id: 4, form_id:, answer_type:, answer_settings:) }
      let(:answer_type) { "text" }
      let(:answer_settings) { {} }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{form_id}/pages/#{page.id}", headers, page.to_json, 200
        end
      end

      describe "api" do
        it "finds the page through ActiveResource" do
          described_class.find(page_id: page.id, form_id:)
          expect(Api::V1::PageResource.new(id: page.id, form_id:)).to have_been_read
        end
      end

      describe "database" do
        it "saves the page to the database" do
          expect {
            described_class.find(page_id: page.id, form_id:)
          }.to change(Page, :count).by(1)
        end

        it "returns a page record" do
          expect(described_class.find(page_id: page.id, form_id:)).to be_a(Page)
        end

        it "associates the page with a form" do
          described_class.find(page_id: page.id, form_id:)
          expect(Page.last).to have_attributes(form_id:)
        end

        context "when the form does not exist in the database" do
          let(:form_id) { 1 }
          let(:form) { build(:form_resource, id: form_id) }

          it "gets the form from the api and saves it to the database" do
            ActiveResource::HttpMock.respond_to(false) do |mock|
              mock.get "/api/v1/forms/1", headers, form.to_json, 200
            end

            expect {
              described_class.find(page_id: page.id, form_id:)
            }.to change(Form, :count).by(1)
          end
        end

        context "when the page has routing conditions" do
          let(:routing_conditions) do
            [
              build(:condition_resource, id: 1, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Red"),
              build(:condition_resource, id: 2, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Green"),
            ]
          end

          let(:page) { build(:page_resource, id: 2, form_id:, routing_conditions:) }

          it "saves the conditions to the database" do
            expect {
              described_class.find(page_id: page.id, form_id:)
            }.to change(Condition, :count).by(2)
          end

          context "when the page in the database has conditions which were deleted in the api" do
            it "deletes conditions from the database" do
              described_class.find(page_id: page.id, form_id:)

              page.routing_conditions = routing_conditions.drop(1)
              ActiveResource::HttpMock.respond_to do |mock|
                mock.get "/api/v1/forms/#{form_id}/pages/2", headers, page.to_json, 200
              end

              expect {
                described_class.find(page_id: page.id, form_id:)
              }.to change(Condition, :count).by(-1)
            end
          end
        end

        context "when the page has answer settings" do
          let(:answer_type) { "selection" }
          let(:answer_settings) { { only_one_option: "true", selection_options: [{ name: "Option 1" }] } }

          it "saves the answer settings to the database" do
            described_class.find(page_id: page.id, form_id:)
            expect(Page.find(page.id)).to have_attributes(
              "answer_settings" => DataStruct.new({
                "only_one_option" => "true",
                "selection_options" => [DataStruct.new({ name: "Option 1" })],
              }),
            )
          end
        end

        context "when the page is already in the database" do
          let!(:existing_page) { create(:page_record, id: page.id, form_id:) }

          it "does not create a new page" do
            expect {
              described_class.find(page_id: existing_page.id, form_id:)
            }.not_to change(Page, :count)
          end

          it "returns the existing page" do
            expect(described_class.find(page_id: existing_page.id, form_id:)).to eq(existing_page)
          end
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
      let(:created_page_id) { 4 }
      let(:answer_settings) { {} }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/#{form_id}/pages", post_headers, build(:page_resource, page_params.merge(id: created_page_id)).to_json, 200
        end
      end

      describe "api" do
        it "creates a page through ActiveResource" do
          described_class.create!(**page_params)
          expect(Api::V1::PageResource.new(page_params)).to have_been_created
        end
      end

      describe "database" do
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
            expect(Page.find(created_page_id)).to have_attributes(
              "answer_settings" => DataStruct.new({
                "only_one_option" => "true",
                "selection_options" => [],
              }),
            )
          end
        end
      end

      it "has the same ID in the database and for the API" do
        described_class.create!(**page_params)
        expect(Page.last.id).to eq created_page_id
      end
    end

    describe "#save!" do
      let(:page) { create(:page_record, form:, is_optional: false, question_text: "database page") }
      let(:updated_page_resource) { build(:page_resource, id: page.id, form_id:, is_optional: true, question_text: "API page") }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/#{form_id}/pages/#{page.id}", post_headers, updated_page_resource.to_json, 200
        end
      end

      describe "api" do
        it "updates the page through ActiveResource" do
          page.is_optional = true
          described_class.save!(page)
          expect(Api::V1::PageResource.new(id: page.id, form_id:, is_optional: true)).to have_been_updated
          expect(JSON.parse(ActiveResource::HttpMock.requests.first.body)).to include("is_optional" => true)
        end

        it "returns a page constructed from the API response" do
          described_class.save!(page)
          expect(described_class.save!(page)).to have_attributes(question_text: "API page")
        end
      end

      describe "database" do
        it "saves the page to the database" do
          page.is_optional = true

          ActiveResource::HttpMock.respond_to do |mock|
            mock.put "/api/v1/forms/#{form_id}/pages/#{page.id}", put_headers, page.to_json
          end

          expect {
            described_class.save!(page)
          }.to change { Page.find(page.id).is_optional }.to(true)
        end

        it "returns a page record" do
          expect(described_class.save!(page)).to be_a(Page)
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
            ActiveResource::HttpMock.respond_to do |mock|
              mock.put "/api/v1/forms/#{form_id}/pages/#{page.id}", put_headers, updated_page_resource.to_json
            end

            expect {
              described_class.save!(page)
            }.not_to(change { Form.find(form_id).question_section_completed })
          end
        end

        context "when there are changes to save" do
          let(:form) { create(:form_record, question_section_completed: true) }

          it "updates the form" do
            page.is_optional = true

            ActiveResource::HttpMock.respond_to do |mock|
              mock.put "/api/v1/forms/#{form_id}/pages/#{page.id}", put_headers, updated_page_resource.to_json
            end

            expect {
              described_class.save!(page)
            }.to change { Form.find(form_id).question_section_completed }.to(false)
          end
        end
      end
    end

    describe "#destroy" do
      let(:page) { create(:page_record, form_id:) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete "/api/v1/forms/#{form_id}/pages/#{page.id}", delete_headers, nil, 204
        end
      end

      describe "api" do
        it "destroys the page through ActiveResource" do
          described_class.destroy(page)
          expect(Api::V1::PageResource.new(id: page.id, form_id:)).to have_been_deleted
        end

        context "when the page has already been deleted" do
          it "does not raise an error" do
            described_class.destroy(page)

            ActiveResource::HttpMock.respond_to do |mock|
              mock.delete "/api/v1/forms/#{form_id}/pages/#{page.id}", delete_headers, nil, 404
            end

            expect {
              described_class.destroy(page)
            }.not_to raise_error
          end

          it "still deletes the page from the database" do
            ActiveResource::HttpMock.respond_to do |mock|
              mock.delete "/api/v1/forms/#{form_id}/pages/#{page.id}", delete_headers, nil, 404
            end

            expect {
              described_class.destroy(page)
            }.to change(Page, :count).by(-1)
          end
        end
      end

      describe "database" do
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
      end

      it "returns the deleted page" do
        expect(described_class.destroy(page)).to eq page
      end

      context "when the page has already been deleted" do
        it "returns the deleted page" do
          described_class.destroy(page)

          ActiveResource::HttpMock.respond_to do |mock|
            mock.delete "/api/v1/forms/#{form_id}/pages/#{page.id}", delete_headers, nil, 404
          end

          expect(described_class.destroy(page)).to eq page
        end
      end
    end

    describe "#move_page" do
      let(:page) { create(:page_record, form_id:, position: 2) }
      let(:moved_page_resource) { build(:page_resource, id: page.id, form_id:, position: 1) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/#{form_id}/pages/#{page.id}/up", post_headers, moved_page_resource.to_json, 200
        end
      end

      describe "api" do
        it "calls the move endpoint through ActiveResource" do
          move_request = ActiveResource::Request.new(:put, "/api/v1/forms/#{form_id}/pages/#{page.id}/up", {}, post_headers)
          described_class.move_page(page, :up)
          expect(ActiveResource::HttpMock.requests).to include move_request
        end
      end

      describe "database" do
        it "updates the page in the database" do
          expect {
            described_class.move_page(page, :up)
          }.to change { Page.find(page.id).position }.from(2).to(1)
        end

        it "returns a page record" do
          expect(described_class.move_page(page, :up)).to be_a(Page)
        end

        context "when the form question section is complete" do
          let(:form) { create(:form_record, question_section_completed: true) }

          it "updates the form to mark the question section as incomplete" do
            expect {
              described_class.move_page(page, :up)
            }.to change { Form.find(form_id).question_section_completed }.to(false)
          end
        end

        context "when the page has routing conditions" do
          before do
            create(:condition_record, routing_page_id: page.id, check_page_id: page.id, goto_page_id: nil, skip_to_end: true, answer_value: "Red")
            create(:condition_record, routing_page_id: page.id, check_page_id: page.id, goto_page_id: nil, skip_to_end: true, answer_value: "Green")
            page.reload
          end

          let(:page) { create(:page_record, form_id:, position: 2) }
          let(:moved_page_resource) { build(:page_resource, id: page.id, form_id:, position: 1) }

          it "does not raise an error" do
            expect {
              described_class.move_page(page, :up)
            }.not_to raise_error
          end
        end
      end
    end
  end

  context "when use_database_as_truth is true" do
    before do
      allow(Settings).to receive(:use_database_as_truth).and_return(true)
    end

    describe "#find" do
      let(:page) { create(:page_record, form:) }

      it "does not call the API" do
        described_class.find(page_id: page.id, form_id:)
        expect(Api::V1::PageResource.new(id: page.id, form_id:)).not_to have_been_read
      end

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
      let(:ignored_api_page_id) { 999_999 }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/#{form_id}/pages", post_headers, build(:page_resource, page_params.merge(id: ignored_api_page_id)).to_json, 200
        end
      end

      describe "api" do
        it "creates a page through ActiveResource" do
          page = described_class.create!(**page_params)
          expect(Api::V1::PageResource.new(page.attributes)).to have_been_created
        end
      end

      describe "database" do
        it "saves the new page to the database" do
          expect {
            described_class.create!(**page_params)
          }.to change(Page, :count).by(1)
        end

        it "returns a page record" do
          expect(described_class.create!(**page_params)).to be_a(Page)
        end

        it "doesn't use the API response to create the page" do
          expect(described_class.create!(**page_params).id).not_to eq(ignored_api_page_id)
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

      it "has the same ID in the database and for the API" do
        described_class.create!(**page_params)
        expect(JSON.parse(ActiveResource::HttpMock.requests.first.body)).to include("id" => Page.last.id)
      end
    end

    describe "#save!" do
      let(:page) { create(:page_record, form:, is_optional: false, question_text: "database page") }
      let(:updated_page_resource) { build(:page_resource, id: page.id, form_id:, is_optional: true, question_text: "API page") }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/#{form_id}/pages/#{page.id}", post_headers, updated_page_resource.to_json, 200
        end
      end

      describe "api" do
        it "updates the page through ActiveResource" do
          page.is_optional = true
          described_class.save!(page)
          expect(Api::V1::PageResource.new(id: page.id, form_id:, is_optional: true)).to have_been_updated
          expect(JSON.parse(ActiveResource::HttpMock.requests.first.body)).to include("is_optional" => true)
        end
      end

      describe "database" do
        it "saves the page to the database" do
          page.is_optional = true

          ActiveResource::HttpMock.respond_to do |mock|
            mock.put "/api/v1/forms/#{form_id}/pages/#{page.id}", put_headers, page.to_json
          end

          expect {
            described_class.save!(page)
          }.to change { Page.find(page.id).is_optional }.to(true)
        end

        it "returns the database page" do
          expect(described_class.save!(page)).to eq(page)
        end

        it "doesn't use the API response to udpate the page" do
          expect(described_class.save!(page).question_text).to eq("database page")
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
            ActiveResource::HttpMock.respond_to do |mock|
              mock.put "/api/v1/forms/#{form_id}/pages/#{page.id}", put_headers, updated_page_resource.to_json
            end

            expect {
              described_class.save!(page)
            }.not_to(change { Form.find(form_id).question_section_completed })
          end
        end

        context "when there are changes to save" do
          let(:form) { create(:form_record, question_section_completed: true) }

          it "updates the form" do
            page.is_optional = true

            ActiveResource::HttpMock.respond_to do |mock|
              mock.put "/api/v1/forms/#{form_id}/pages/#{page.id}", put_headers, updated_page_resource.to_json
            end

            expect {
              described_class.save!(page)
            }.to change { Form.find(form_id).question_section_completed }.to(false)
          end
        end
      end
    end

    describe "#destroy" do
      let(:page) { create(:page_record, form_id:) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete "/api/v1/forms/#{form_id}/pages/#{page.id}", delete_headers, nil, 204
        end
      end

      describe "api" do
        it "destroys the page through ActiveResource" do
          described_class.destroy(page)
          expect(Api::V1::PageResource.new(id: page.id, form_id:)).to have_been_deleted
        end

        context "when the page has already been deleted" do
          it "does not raise an error" do
            described_class.destroy(page)

            ActiveResource::HttpMock.respond_to do |mock|
              mock.delete "/api/v1/forms/#{form_id}/pages/#{page.id}", delete_headers, nil, 404
            end

            expect {
              described_class.destroy(page)
            }.not_to raise_error
          end

          it "still deletes the page from the database" do
            ActiveResource::HttpMock.respond_to do |mock|
              mock.delete "/api/v1/forms/#{form_id}/pages/#{page.id}", delete_headers, nil, 404
            end

            expect {
              described_class.destroy(page)
            }.to change(Page, :count).by(-1)
          end
        end
      end

      describe "database" do
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
      end

      it "returns the deleted page" do
        expect(described_class.destroy(page)).to eq page
      end

      context "when the page has already been deleted" do
        it "returns the deleted page" do
          described_class.destroy(page)

          ActiveResource::HttpMock.respond_to do |mock|
            mock.delete "/api/v1/forms/#{form_id}/pages/#{page.id}", delete_headers, nil, 404
          end

          expect(described_class.destroy(page)).to eq page
        end
      end
    end

    describe "#move_page" do
      let(:form) { create(:form_record, :with_pages) }
      let(:page) { form.pages.second }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/#{form_id}/pages/#{page.id}", post_headers, {}, 200
        end
      end

      describe "api" do
        it "sends the new page position to the API" do
          described_class.move_page(page, :up)
          expect(JSON.parse(ActiveResource::HttpMock.requests.last.body)).to include("position" => 1)
        end
      end

      describe "database" do
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
  end
end
