require "rails_helper"

describe FormRepository do
  describe "#create!" do
    let(:form_params) { { creator_id: 1, name: "asdf" } }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms", post_headers, build(:form_resource, form_params.merge(id: 1)).to_json, 200
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

      it "sets the external ID" do
        described_class.create!(**form_params)
        form = Form.last
        expect(form).to have_attributes id: 1, external_id: "1"
      end
    end

    it "has the same ID in the database and for the API" do
      api_form = described_class.create!(**form_params)
      database_form = Form.last
      expect(api_form.id).to eq database_form.id
    end

    it "has the same external ID in the database as the API ID" do
      api_form = described_class.create!(**form_params)
      database_form = Form.last
      expect(database_form.external_id).to eq api_form.id.to_s
    end
  end

  describe "#find" do
    let(:form) { build(:form_resource, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
      end
    end

    describe "api" do
      it "finds the form through ActiveResource" do
        described_class.find(form_id: 2)
        expect(Api::V1::FormResource.new(id: 2)).to have_been_read
      end
    end

    describe "database" do
      it "saves the form to the the database" do
        expect {
          described_class.find(form_id: 2)
        }.to change(Form, :count).by(1)
      end
    end

    it "has the same ID in the database and for the API" do
      described_class.find(form_id: 2)
      expect(Form.last.id).to eq 2
    end

    it "has the same external ID in the database as the API ID" do
      api_form = described_class.find(form_id: 2)
      database_form = Form.last
      expect(database_form.external_id).to eq api_form.id.to_s
    end
  end

  describe "#find_live" do
    let(:form) { build(:form_resource, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2/live", headers, form.to_json, 200
      end
    end

    describe "api" do
      it "calls the find_live endpoint through ActiveResource" do
        find_live_request = ActiveResource::Request.new(:get, "/api/v1/forms/2/live", form, headers)
        described_class.find_live(form_id: 2)
        expect(ActiveResource::HttpMock.requests).to include find_live_request
      end
    end

    describe "database" do
      it "does not save anything to the database" do
        expect {
          described_class.find_live(form_id: 2)
        }.not_to change(Form, :count)
      end
    end
  end

  describe "#find_archived" do
    let(:form) { build(:form_resource, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2/archived", headers, form.to_json, 200
      end
    end

    describe "api" do
      it "calls the find_archived endpoint through ActiveResource" do
        find_archived_request = ActiveResource::Request.new(:get, "/api/v1/forms/2/archived", form, headers)
        described_class.find_archived(form_id: 2)
        expect(ActiveResource::HttpMock.requests).to include find_archived_request
      end
    end

    describe "database" do
      it "does not save anything to the database" do
        expect {
          described_class.find_archived(form_id: 2)
        }.not_to change(Form, :count)
      end
    end
  end

  describe "#where" do
    let(:form) { build(:form_resource, id: 2, creator_id: 3) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?creator_id=3", headers, [form].to_json, 200
      end
    end

    describe "api" do
      it "calls the where endpoint through ActiveResource" do
        where_request = ActiveResource::Request.new(:get, "/api/v1/forms?creator_id=3", [form], headers)
        described_class.where(creator_id: 3)
        expect(ActiveResource::HttpMock.requests).to include where_request
      end
    end

    describe "database" do
      it "does not save anything to the database" do
        expect {
          described_class.where(creator_id: 3)
        }.not_to change(Form, :count)
      end
    end
  end

  describe "#save!" do
    let(:form) { build(:form_resource, id: 2, name: "original name") }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.put "/api/v1/forms/2", post_headers
      end
    end

    describe "api" do
      it "updates the form through ActiveResource" do
        form = described_class.find(form_id: 2)
        form.name = "new name"
        described_class.save!(form)
        expect(Api::V1::FormResource.new(id: 2, name: "new name")).to have_been_updated
      end
    end

    describe "database" do
      it "saves the form to the the database" do
        form = described_class.find(form_id: 2)
        form.name = "new name"

        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/2", put_headers, form.to_json
        end

        expect {
          described_class.save!(form)
        }.to change { Form.find(2).name }.to("new name")
      end
    end
  end

  describe "#make_live!" do
    let(:form) { build(:form_resource, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.post "/api/v1/forms/2/make-live", post_headers, form.as_json.merge(state: :live).to_json, 200
      end
    end

    describe "api" do
      it "calls the make-live endpoint through ActiveResource" do
        make_live_request = ActiveResource::Request.new(:post, "/api/v1/forms/2/make-live", {}, post_headers)
        described_class.make_live!(form)
        expect(ActiveResource::HttpMock.requests).to include make_live_request
      end
    end

    describe "database" do
      it "saves the form to the database" do
        form = described_class.find(form_id: 2)
        expect {
          described_class.make_live!(form)
        }.to change { Form.find(2).state }.to("live")
      end
    end
  end

  describe "#archive!" do
    let(:form) { build(:form_resource, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.post "/api/v1/forms/2/archive", post_headers, form.as_json.merge(state: :archived).to_json, 200
      end
    end

    describe "api" do
      it "calls the archive endpoint through ActiveResource" do
        archive_request = ActiveResource::Request.new(:post, "/api/v1/forms/2/archive", {}, post_headers)
        described_class.archive!(form)
        expect(ActiveResource::HttpMock.requests).to include archive_request
      end
    end

    describe "database" do
      it "saves the form to the database" do
        form = described_class.find(form_id: 2)
        expect {
          described_class.archive!(form)
        }.to change { Form.find(2).state }.to("archived")
      end
    end
  end

  describe "#destroy" do
    let(:form) { build(:form_resource, :live, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.delete "/api/v1/forms/2", delete_headers, nil, 204
      end
    end

    describe "api" do
      it "destroys the form through ActiveResource" do
        form = described_class.find(form_id: 2)
        described_class.destroy(form)
        expect(Api::V1::FormResource.new(id: 2)).to have_been_deleted
      end
    end

    describe "database" do
      it "removes the form from the database" do
        form = described_class.find(form_id: 2)
        expect {
          described_class.destroy(form)
        }.to change(Form, :count).by(-1)
      end

      context "when the form is not already in the database" do
        it "does not raise an error" do
          form = Api::V1::FormResource.new(id: 2)
          expect {
            described_class.destroy(form)
          }.not_to raise_error
        end
      end
    end

    it "returns the deleted form" do
      form = described_class.find(form_id: 2)
      expect(described_class.destroy(form)).to eq form
    end

    context "when the form has already been deleted" do
      it "does not raise an error" do
        form = described_class.find(form_id: 2)
        described_class.destroy(form)

        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete "/api/v1/forms/2", delete_headers, nil, 404
        end

        expect {
          described_class.destroy(form)
        }.not_to raise_error
      end

      it "returns the deleted form" do
        form = described_class.find(form_id: 2)
        described_class.destroy(form)

        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete "/api/v1/forms/2", delete_headers, nil, 404
        end

        expect(described_class.destroy(form)).to eq form
      end
    end
  end

  describe "#pages" do
    let(:form) do
      form = build(:form_resource, id: 2)
      Form.upsert(form.database_attributes)
      form
    end
    let(:pages) { build_list(:page_resource, 5) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
      end
    end

    describe "api" do
      it "gets a form's pages through ActiveResource" do
        pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2/pages", pages, headers)
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

      context "when the form in the database has pages which were deleted in the api" do
        it "deletes pages from the database" do
          pages = described_class.pages(form)

          pages = pages.drop(1)
          ActiveResource::HttpMock.respond_to do |mock|
            mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
          end

          expect {
            described_class.pages(form)
          }.to change(Page, :count).by(-1)
        end

        context "and page had routing_conditions" do
          let(:pages) do
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
            pages = described_class.pages(form)

            pages = pages.drop(2)
            ActiveResource::HttpMock.respond_to do |mock|
              mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
            end

            expect {
              described_class.pages(form)
            }.to change(Page, :count).by(-2)
              .and change(Condition, :count).by(-2)
          end
        end
      end

      context "when the pages have routing conditions" do
        let(:pages) do
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
            pages = described_class.pages(form)

            pages.second.routing_conditions = routing_conditions.drop(1)
            ActiveResource::HttpMock.respond_to do |mock|
              mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
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
