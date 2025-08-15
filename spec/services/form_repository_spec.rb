require "rails_helper"

describe FormRepository do
  context "when use_database_as_truth is false" do
    before do
      allow(Settings).to receive(:use_database_as_truth).and_return(false)
    end

    describe "#create!" do
      let(:form_params) { { creator_id: 1, name: "asdf" } }
      let(:created_form_id) { 4 }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms", post_headers, build(:form_resource, form_params.merge(id: created_form_id)).to_json, 200
        end
      end

      describe "api" do
        it "creates a form through ActiveResource" do
          described_class.create!(**form_params)
          expect(Api::V1::FormResource.new(form_params)).to have_been_created
        end
      end

      describe "database" do
        it "saves the form to the the database" do
          expect {
            described_class.create!(**form_params)
          }.to change(Form, :count).by(1)
        end

        it "returns a form record" do
          expect(described_class.create!(**form_params)).to be_a(Form)
        end

        it "sets the external ID" do
          described_class.create!(**form_params)
          expect(Form.find(created_form_id)).to have_attributes id: created_form_id, external_id: created_form_id.to_s
        end
      end

      it "has the same ID in the database and for the API" do
        described_class.create!(**form_params)
        expect(Form.last.id).to eq created_form_id
      end
    end

    describe "#find" do
      let(:form) { build(:form_resource, id: 2) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{form.id}", headers, form.to_json, 200
        end
      end

      describe "api" do
        it "finds the form through ActiveResource" do
          described_class.find(form_id: form.id)
          expect(Api::V1::FormResource.new(id: form.id)).to have_been_read
        end
      end

      describe "database" do
        it "saves the form to the the database" do
          expect {
            described_class.find(form_id: form.id)
          }.to change(Form, :count).by(1)
        end

        it "returns a form record" do
          expect(described_class.find(form_id: form.id)).to be_a(Form)
        end

        it "has the same ID in the database and for the API" do
          described_class.find(form_id: form.id)
          expect(Form.last.id).to eq form.id
        end

        it "has the same external ID in the database as the API ID" do
          described_class.find(form_id: form.id)
          expect(Form.find(form.id).external_id).to eq form.id.to_s
        end

        context "when the form already exists in the database" do
          let!(:form_record) { create(:form_record, id: form.id) }

          it "does not create a new form" do
            expect {
              described_class.find(form_id: form_record.id)
            }.not_to change(Form, :count)
          end

          it "returns the existing form" do
            expect(described_class.find(form_id: form_record.id)).to eq(form_record)
          end
        end
      end
    end

    describe "#find_live" do
      let(:form) { build(:made_live_form, id: 2) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{form.id}/live", headers, form.to_json, 200
        end
      end

      describe "api" do
        it "calls the find_live endpoint through ActiveResource" do
          find_live_request = ActiveResource::Request.new(:get, "/api/v1/forms/#{form.id}/live", form, headers)
          described_class.find_live(form_id: form.id)
          expect(ActiveResource::HttpMock.requests).to include find_live_request
        end
      end

      describe "database" do
        it "does not save anything to the database" do
          expect {
            described_class.find_live(form_id: form.id)
          }.not_to change(Form, :count)
        end
      end
    end

    describe "#find_archived" do
      let(:form) { build(:made_live_form, id: 2) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{form.id}/archived", headers, form.to_json, 200
        end
      end

      describe "api" do
        it "calls the find_archived endpoint through ActiveResource" do
          find_archived_request = ActiveResource::Request.new(:get, "/api/v1/forms/#{form.id}/archived", form, headers)
          described_class.find_archived(form_id: form.id)
          expect(ActiveResource::HttpMock.requests).to include find_archived_request
        end
      end

      describe "database" do
        it "does not save anything to the database" do
          expect {
            described_class.find_archived(form_id: form.id)
          }.not_to change(Form, :count)
        end
      end
    end

    describe "#where" do
      let(:form) { build(:form_resource, id: 2, creator_id: 3) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms?creator_id=#{form.creator_id}", headers, [form].to_json, 200
        end
      end

      describe "api" do
        it "calls the where endpoint through ActiveResource" do
          where_request = ActiveResource::Request.new(:get, "/api/v1/forms?creator_id=#{form.creator_id}", [form], headers)
          described_class.where(creator_id: form.creator_id)
          expect(ActiveResource::HttpMock.requests).to include where_request
        end
      end

      describe "database" do
        it "does not save anything to the database" do
          expect {
            described_class.where(creator_id: form.creator_id)
          }.not_to change(Form, :count)
        end
      end
    end

    describe "#save!" do
      let(:form) { create(:form_record, name: "original name", creator_id: 3) }
      let(:updated_form_resource) { build(:form_resource, id: form.id, name: "new name", creator_id: 5) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/#{form.id}", post_headers, updated_form_resource.to_json, 200
        end
      end

      describe "api" do
        it "updates the form through ActiveResource" do
          form.name = "new name"
          described_class.save!(form)
          expect(Api::V1::FormResource.new(id: form.id, name: "new name")).to have_been_updated
          expect(JSON.parse(ActiveResource::HttpMock.requests.first.body)).to include("name" => "new name")
        end

        it "returns a form constructed from the API response" do
          expect(described_class.save!(form)).to have_attributes(creator_id: 5)
        end
      end

      describe "database" do
        it "saves the form to the the database" do
          form.name = "new name"

          expect {
            described_class.save!(form)
          }.to change { Form.find(form.id).name }.to("new name")
        end

        it "returns a form record" do
          expect(described_class.save!(form)).to be_a(Form)
        end

        context "when the form is live" do
          let(:form) { create(:form, :live) }
          let(:updated_form_resource) { build(:form_resource, :live, id: form.id) }

          it "changes the form's state to live_with_draft" do
            expect {
              described_class.save!(form)
            }.to change { Form.find(form.id).state }.to("live_with_draft")
          end
        end

        context "when the form is archived" do
          let(:form) { create(:form, :archived) }
          let(:updated_form_resource) { build(:form_resource, :archived, id: form.id) }

          it "changes the form's state to archived_with_draft" do
            expect {
              described_class.save!(form)
            }.to change { Form.find(form.id).state }.to("archived_with_draft")
          end
        end
      end
    end

    describe "#make_live!" do
      let(:form) { create(:form_record, :live_with_draft) }
      let(:live_form_resource) { build(:form_resource, :live, id: form.id) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/#{form.id}/make-live", post_headers, live_form_resource.to_json, 200
        end
      end

      describe "api" do
        it "calls the make-live endpoint through ActiveResource" do
          make_live_request = ActiveResource::Request.new(:post, "/api/v1/forms/#{form.id}/make-live", {}, post_headers)
          described_class.make_live!(form)
          expect(ActiveResource::HttpMock.requests).to include make_live_request
        end
      end

      describe "database" do
        it "saves the form to the database" do
          expect {
            described_class.make_live!(form)
          }.to change { Form.find(form.id).state }.to("live")
        end

        it "returns a form record" do
          expect(described_class.make_live!(form)).to be_a(Form)
        end

        context "when there are no pages for the form in the database" do
          let(:form) { create(:form_record, :live_with_draft, pages_count: 0) }

          before do
            ActiveResource::HttpMock.respond_to do |mock|
              mock.post "/api/v1/forms/#{form.id}/make-live", post_headers, live_form_resource.to_json, 200
              mock.get "/api/v1/forms/#{form.id}/pages", headers, live_form_resource.pages.to_json, 200
            end
          end

          it "save the form pages to the database" do
            expect {
              described_class.make_live!(form)
            }.to(change { form.reload.pages.length })
          end
        end

        context "when the form has a draft" do
          let(:form) { create(:form, :live_with_draft) }

          it "touches the form" do
            expect {
              described_class.make_live!(form)
            }.to(change { Form.find(form.id).updated_at })
          end
        end
      end
    end

    describe "#archive!" do
      let(:form) { create(:form_record, :live) }
      let(:archived_form_resource) { build(:form_resource, :archived, id: form.id) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/#{form.id}/archive", post_headers, archived_form_resource.to_json, 200
        end
      end

      describe "api" do
        it "calls the archive endpoint through ActiveResource" do
          archive_request = ActiveResource::Request.new(:post, "/api/v1/forms/#{form.id}/archive", {}, post_headers)
          described_class.archive!(form)
          expect(ActiveResource::HttpMock.requests).to include archive_request
        end
      end

      describe "database" do
        it "archives the form in the database" do
          expect {
            described_class.archive!(form)
          }.to change { Form.find(form.id).state }.to("archived")
        end

        it "returns a form record" do
          expect(described_class.archive!(form)).to be_a(Form)
        end
      end
    end

    describe "#destroy" do
      let(:form) { create(:form_record) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete "/api/v1/forms/#{form.id}", delete_headers, {}, 204
        end
      end

      describe "api" do
        it "destroys the form through ActiveResource" do
          described_class.destroy(form)
          expect(Api::V1::FormResource.new(id: form.id)).to have_been_deleted
        end
      end

      describe "database" do
        it "removes the form from the database" do
          expect {
            described_class.destroy(form)
          }.to change(Form, :count).by(-1)
        end

        it "returns a form record" do
          expect(described_class.destroy(form)).to be_a(Form)
        end

        context "when the form is not already in the database" do
          it "does not raise an error" do
            expect {
              described_class.destroy(form)
            }.not_to raise_error
          end
        end
      end

      it "returns the deleted form" do
        expect(described_class.destroy(form)).to eq form
      end

      context "when the form has already been deleted" do
        it "does not raise an error" do
          described_class.destroy(form)

          ActiveResource::HttpMock.respond_to do |mock|
            mock.delete "/api/v1/forms/#{form.id}", delete_headers, nil, 404
          end

          expect {
            described_class.destroy(form)
          }.not_to raise_error
        end

        it "still deletes the form from the database" do
          expect {
            described_class.destroy(form)
          }.to change(Form, :count).by(-1)
        end

        it "returns the deleted form" do
          described_class.destroy(form)

          ActiveResource::HttpMock.respond_to do |mock|
            mock.delete "/api/v1/forms/#{form.id}", delete_headers, nil, 404
          end

          expect(described_class.destroy(form)).to eq form
        end
      end
    end

    describe "#pages" do
      let(:form) { create(:form_record) }
      let(:resource_pages) { form_resource.pages }
      let(:form_resource) { build(:form_resource, :with_pages, id: form.id) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{form.id}/pages", headers, resource_pages.to_json, 200
        end
      end

      describe "api" do
        it "gets a form's pages through ActiveResource" do
          pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/#{form.id}/pages", {}, headers)
          described_class.pages(form)
          expect(ActiveResource::HttpMock.requests).to include pages_request
        end
      end

      describe "database" do
        it "saves the pages to the database" do
          expect {
            described_class.pages(form)
          }.to change(Page, :count).by(5)
        end

        it "returns page records" do
          expect(described_class.pages(form).first).to be_a(Page)
        end

        context "when the form in the database has pages which were deleted in the api" do
          it "deletes pages from the database" do
            # ensure that pages exist in the db with the same IDs as the API pages
            described_class.pages(form)

            ActiveResource::HttpMock.respond_to do |mock|
              mock.get "/api/v1/forms/#{form.id}/pages", headers, resource_pages.drop(1).to_json, 200
            end

            expect {
              described_class.pages(form)
            }.to change(Page, :count).by(-1)
          end

          context "and page had routing_conditions" do
            let(:form_resource) { build(:form_resource, pages: resource_pages, id: form.id) }
            let(:resource_pages) do
              [
                build(:page_resource, id: 1),
                build(:page_resource, id: 2, routing_conditions:),
                *build_list(:page_resource, 5),
              ]
            end

            let(:routing_conditions) do
              [
                build(:condition_resource, id: 1, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Red"),
                build(:condition_resource, id: 2, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Green"),
              ]
            end

            it "deletes conditions from the database" do
              described_class.pages(form)

              ActiveResource::HttpMock.respond_to do |mock|
                mock.get "/api/v1/forms/#{form.id}/pages", headers, resource_pages.drop(2).to_json, 200
              end

              expect {
                described_class.pages(form)
              }.to change(Page, :count).by(-2)
                .and change(Condition, :count).by(-2)
            end
          end
        end

        context "when the pages have routing conditions" do
          let(:form_resource) { build(:form_resource, pages: resource_pages, id: form.id) }
          let(:resource_pages) do
            [
              build(:page_resource, id: 1),
              build(:page_resource, id: 2, routing_conditions:),
              *build_list(:page_resource, 5),
            ]
          end

          let(:routing_conditions) do
            [
              build(:condition_resource, id: 1, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Red"),
              build(:condition_resource, id: 2, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Green"),
            ]
          end

          it "saves the routing conditions to the database" do
            expect {
              described_class.pages(form)
            }.to change(Condition, :count).by(2)
          end

          context "when the page in the database has conditions which were deleted in the api" do
            it "deletes conditions from the database" do
              described_class.pages(form)

              resource_pages.second.routing_conditions = routing_conditions.drop(1)
              ActiveResource::HttpMock.respond_to do |mock|
                mock.get "/api/v1/forms/#{form.id}/pages", headers, resource_pages.to_json, 200
              end

              expect {
                described_class.pages(form)
              }.to change(Condition, :count).by(-1)
            end
          end
        end
      end
    end
  end

  context "when use_database_as_truth is true" do
    before do
      allow(Settings).to receive(:use_database_as_truth).and_return(true)
    end

    describe "#create!" do
      let(:form_params) { { creator_id: 1, name: "asdf" } }
      let(:ignored_api_form_id) { 999_999 }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms", post_headers, { id: ignored_api_form_id }.to_json, 200
        end
      end

      describe "api" do
        it "creates a form through ActiveResource" do
          form = described_class.create!(**form_params)
          expect(Api::V1::FormResource.new(form.attributes)).to have_been_created
        end
      end

      describe "database" do
        it "saves the form to the the database" do
          expect {
            described_class.create!(**form_params)
          }.to change(Form, :count).by(1)
        end

        it "returns a form record" do
          expect(described_class.create!(**form_params)).to be_a(Form)
        end

        it "doesn't use the API response to create the form" do
          expect(described_class.create!(**form_params).id).not_to eq(ignored_api_form_id)
        end

        it "sets the external ID" do
          form = described_class.create!(**form_params)
          expect(form).to have_attributes external_id: form.id.to_s
        end
      end

      it "has the same ID in the database and for the API" do
        described_class.create!(**form_params)
        expect(JSON.parse(ActiveResource::HttpMock.requests.first.body)).to include("id" => Form.last.id)
      end
    end

    describe "#find" do
      let(:form) { create(:form_record) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{form.id}", headers, form.to_json, 200
        end
      end

      it "does not call the API" do
        described_class.find(form_id: form.id)
        expect(Api::V1::FormResource.new(id: form.id)).not_to have_been_read
      end

      it "returns the form" do
        expect(described_class.find(form_id: form.id)).to eq(form)
      end
    end

    describe "#find_live" do
      let(:form) { build(:made_live_form, id: 2) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{form.id}/live", headers, form.to_json, 200
        end
      end

      describe "api" do
        it "calls the find_live endpoint through ActiveResource" do
          find_live_request = ActiveResource::Request.new(:get, "/api/v1/forms/#{form.id}/live", form, headers)
          described_class.find_live(form_id: form.id)
          expect(ActiveResource::HttpMock.requests).to include find_live_request
        end
      end

      describe "database" do
        it "does not save anything to the database" do
          expect {
            described_class.find_live(form_id: form.id)
          }.not_to change(Form, :count)
        end
      end
    end

    describe "#find_archived" do
      let(:form) { build(:made_live_form, id: 2) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/#{form.id}/archived", headers, form.to_json, 200
        end
      end

      describe "api" do
        it "calls the find_archived endpoint through ActiveResource" do
          find_archived_request = ActiveResource::Request.new(:get, "/api/v1/forms/#{form.id}/archived", form, headers)
          described_class.find_archived(form_id: form.id)
          expect(ActiveResource::HttpMock.requests).to include find_archived_request
        end
      end

      describe "database" do
        it "does not save anything to the database" do
          expect {
            described_class.find_archived(form_id: form.id)
          }.not_to change(Form, :count)
        end
      end
    end

    describe "#where" do
      let(:form) { create(:form_record, creator_id: 3) }

      it "does not call the where endpoint through ActiveResource" do
        where_request = ActiveResource::Request.new(:get, "/api/v1/forms?creator_id=#{form.creator_id}", [form], headers)
        described_class.where(creator_id: form.creator_id)
        expect(ActiveResource::HttpMock.requests).not_to include where_request
      end

      it "returns forms with a matching creator id" do
        expect(described_class.where(creator_id: form.creator_id)).to eq([form])
      end
    end

    describe "#save!" do
      let(:form) { create(:form_record, name: "database name", creator_id: 3) }
      let(:updated_form_resource) { build(:form_resource, id: form.id, name: "API name", creator_id: 5) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/#{form.id}", post_headers, updated_form_resource.to_json, 200
        end
      end

      describe "api" do
        it "updates the form through ActiveResource" do
          form.name = "new name"
          described_class.save!(form)
          expect(Api::V1::FormResource.new(id: form.id, name: "new name")).to have_been_updated
          expect(JSON.parse(ActiveResource::HttpMock.requests.first.body)).to include("name" => "new name")
        end
      end

      describe "database" do
        it "saves the form to the the database" do
          form.name = "new name"

          expect {
            described_class.save!(form)
          }.to change { Form.find(form.id).name }.to("new name")
        end

        it "returns a form record" do
          expect(described_class.save!(form)).to be_a(Form)
        end

        it "doesn't use the API response to update the form" do
          expect(described_class.save!(form).creator_id).to eq(3)
        end

        context "when the form is live" do
          let(:form) { create(:form, :live) }
          let(:updated_form_resource) { build(:form_resource, :live, id: form.id) }

          it "changes the form's state to live_with_draft" do
            expect {
              described_class.save!(form)
            }.to change { Form.find(form.id).state }.to("live_with_draft")
          end
        end

        context "when the form is archived" do
          let(:form) { create(:form, :archived) }
          let(:updated_form_resource) { build(:form_resource, :archived, id: form.id) }

          it "changes the form's state to archived_with_draft" do
            expect {
              described_class.save!(form)
            }.to change { Form.find(form.id).state }.to("archived_with_draft")
          end
        end
      end
    end

    describe "#make_live!" do
      let(:form) { create(:form_record, :live_with_draft, name: "database form name") }
      let(:live_form_resource) { build(:form_resource, :live, id: form.id, name: "API form name") }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/#{form.id}/make-live", post_headers, live_form_resource.to_json, 200
        end
      end

      describe "api" do
        it "calls the make-live endpoint through ActiveResource" do
          make_live_request = ActiveResource::Request.new(:post, "/api/v1/forms/#{form.id}/make-live", {}, post_headers)
          described_class.make_live!(form)
          expect(ActiveResource::HttpMock.requests).to include make_live_request
        end
      end

      describe "database" do
        context "when there are a different number of pages for the form in the database and the form in the API" do
          let(:form) { create(:form_record, :live_with_draft, pages_count: 1) }

          it "does not save pages from the API to the database" do
            expect {
              described_class.make_live!(form)
            }.not_to(change { form.reload.pages.length })
          end
        end

        it "returns a form record" do
          expect(described_class.make_live!(form)).to be_a(Form)
        end

        context "when the form has a draft" do
          let(:form) { create(:form, :live_with_draft) }

          it "touches the form" do
            expect {
              described_class.make_live!(form)
            }.to(change { Form.find(form.id).updated_at })
          end
        end
      end
    end

    describe "#archive!" do
      let(:form) { create(:form_record, :live) }
      let(:archived_form_resource) { build(:form_resource, :archived, id: form.id) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms/#{form.id}/archive", post_headers, archived_form_resource.to_json, 200
        end
      end

      describe "api" do
        it "calls the archive endpoint through ActiveResource" do
          archive_request = ActiveResource::Request.new(:post, "/api/v1/forms/#{form.id}/archive", {}, post_headers)
          described_class.archive!(form)
          expect(ActiveResource::HttpMock.requests).to include archive_request
        end
      end

      describe "database" do
        it "archives the form to the database" do
          expect {
            described_class.archive!(form)
          }.to change { Form.find(form.id).state }.to("archived")
        end

        it "returns a Form object" do
          expect(described_class.archive!(form)).to be_a(Form)
        end
      end
    end

    describe "#destroy" do
      let(:form) { create(:form_record) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete "/api/v1/forms/#{form.id}", delete_headers, {}, 204
        end
      end

      describe "api" do
        it "destroys the form through ActiveResource" do
          described_class.destroy(form)
          expect(Api::V1::FormResource.new(id: form.id)).to have_been_deleted
        end
      end

      describe "database" do
        it "removes the form from the database" do
          expect {
            described_class.destroy(form)
          }.to change(Form, :count).by(-1)
        end

        it "returns a Form object" do
          expect(described_class.destroy(form)).to be_a(Form)
        end

        context "when the form is not already in the database" do
          it "does not raise an error" do
            expect {
              described_class.destroy(form)
            }.not_to raise_error
          end
        end
      end

      it "returns the deleted form" do
        expect(described_class.destroy(form)).to eq form
      end

      context "when the form has already been deleted" do
        it "does not raise an error" do
          described_class.destroy(form)

          ActiveResource::HttpMock.respond_to do |mock|
            mock.delete "/api/v1/forms/#{form.id}", delete_headers, nil, 404
          end

          expect {
            described_class.destroy(form)
          }.not_to raise_error
        end

        it "still deletes the form from the database" do
          expect {
            described_class.destroy(form)
          }.to change(Form, :count).by(-1)
        end

        it "returns the deleted form" do
          described_class.destroy(form)

          ActiveResource::HttpMock.respond_to do |mock|
            mock.delete "/api/v1/forms/#{form.id}", delete_headers, nil, 404
          end

          expect(described_class.destroy(form)).to eq form
        end
      end
    end

    describe "#pages" do
      let(:form) { create(:form_record, :with_pages) }

      it "does not request a form's pages through ActiveResource" do
        pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/#{form.id}/pages", {}, headers)
        described_class.pages(form)
        expect(ActiveResource::HttpMock.requests).not_to include pages_request
      end

      it "returns page records" do
        expect(described_class.pages(form).first).to be_a(Page)
      end
    end
  end
end
