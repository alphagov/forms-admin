require "rails_helper"

describe PageRepository do
  let(:form_id) { form.id }
  let(:form) do
    form = build(:form)
    form.id = Form.create!(form.database_attributes).id
    form
  end

  describe "#find" do
    let(:page) { build(:page, id: 2, form_id:) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/#{form_id}/pages/2", headers, page.to_json, 200
      end
    end

    describe "api" do
      it "finds the page through ActiveResource" do
        described_class.find(page_id: page.id, form_id:)
        expect(Api::V1::PageResource.new(id: 2, form_id:)).to have_been_read
      end
    end

    describe "database" do
      it "saves the page to the database" do
        expect {
          described_class.find(page_id: page.id, form_id:)
        }.to change(Page, :count).by(1)
      end

      it "associates the page with a form" do
        described_class.find(page_id: page.id, form_id:)
        expect(Page.last).to have_attributes(form_id:)
      end

      context "when the form does not exist in the database" do
        let(:form_id) { 1 }
        let(:form) { build(:form, id: form_id) }

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
            build(:condition, id: 1, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Red"),
            build(:condition, id: 2, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Green"),
          ]
        end

        let(:page) { build(:page, id: 2, form_id:, routing_conditions:) }

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

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms/#{form_id}/pages", post_headers, build(:page, page_params.merge(id: 1)).to_json, 200
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

      it "associates the page with a form" do
        described_class.create!(**page_params)
        expect(Page.last).to have_attributes(form_id:)
      end

      context "when the page has answer settings" do
        let(:answer_type) { "selection" }
        let(:answer_settings) { { only_one_option: "true", selection_options: [] } }

        it "saves the answer settings to the database" do
          described_class.create!(**page_params)
          expect(Page.last).to have_attributes(
            "answer_settings" => {
              "only_one_option" => "true",
              "selection_options" => [],
            },
          )
        end
      end
    end

    it "has the same ID in the database and for the API" do
      page = described_class.create!(**page_params)
      expect(Page.last.id).to eq page.id
    end
  end

  describe "#save!" do
    let(:page) { build(:page, id: 2, form_id:, is_optional: false) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/#{form_id}/pages/2", headers, page.to_json, 200
        mock.put "/api/v1/forms/#{form_id}/pages/2", post_headers
      end
    end

    describe "api" do
      it "updates the page through ActiveResource" do
        page = described_class.find(page_id: 2, form_id:)
        page.is_optional = true
        described_class.save!(page)
        expect(Api::V1::PageResource.new(id: 2, form_id:, is_optional: true)).to have_been_updated
      end
    end

    describe "database" do
      it "saves the page to the database" do
        page = described_class.find(page_id: 2, form_id:)
        page.is_optional = true

        ActiveResource::HttpMock.respond_to do |mock|
          mock.put "/api/v1/forms/#{form_id}/pages/2", put_headers, page.to_json
        end

        expect {
          described_class.save!(page)
        }.to change { Page.find(2).is_optional }.to(true)
      end
    end
  end

  describe "#destroy" do
    let(:page) { build(:page, id: 2, form_id:) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/#{form_id}/pages/2", headers, page.to_json, 200
        mock.delete "/api/v1/forms/#{form_id}/pages/2", delete_headers, nil, 204
      end
    end

    describe "api" do
      it "destroys the page through ActiveResource" do
        page = described_class.find(page_id: 2, form_id:)
        described_class.destroy(page)
        expect(Api::V1::PageResource.new(id: 2, form_id:)).to have_been_deleted
      end

      context "when the page has already been deleted" do
        it "does not raise an error" do
          page = described_class.find(page_id: 2, form_id:)
          described_class.destroy(page)

          ActiveResource::HttpMock.respond_to do |mock|
            mock.delete "/api/v1/forms/#{form_id}/pages/2", delete_headers, nil, 404
          end

          expect {
            described_class.destroy(page)
          }.not_to raise_error
        end
      end
    end

    describe "database" do
      it "removes the page from the database" do
        page = described_class.find(page_id: 2, form_id:)

        expect {
          described_class.destroy(page)
        }.to change(Page, :count).by(-1)
      end

      context "when the page has routing conditions" do
        let(:routing_conditions) do
          [
            build(:condition, id: 1, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Red"),
            build(:condition, id: 2, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Green"),
          ]
        end

        let(:page) { build(:page, id: 2, form_id:, routing_conditions:) }

        it "deletes the conditions" do
          page = described_class.find(page_id: 2, form_id:)

          expect {
            described_class.destroy(page)
          }.to change(Condition, :count).by(-2)
        end
      end

      context "when the page is not already in the database" do
        it "does not raise an error" do
          page = Api::V1::PageResource.new(id: 2, form_id:)
          expect {
            described_class.destroy(page)
          }.not_to raise_error
        end
      end
    end

    it "returns the deleted page" do
      page = described_class.find(page_id: 2, form_id:)
      expect(described_class.destroy(page)).to eq page
    end

    context "when the page has already been deleted" do
      it "returns the deleted page" do
        page = described_class.find(page_id: 2, form_id:)
        described_class.destroy(page)

        ActiveResource::HttpMock.respond_to do |mock|
          mock.delete "/api/v1/forms/#{form_id}/pages/2", delete_headers, nil, 404
        end

        expect(described_class.destroy(page)).to eq page
      end
    end
  end

  describe "#move_page" do
    let(:page) { build(:page, id: 2, form_id:, position: 2) }
    let(:moved_page) { build(:page, id: 2, form_id:, position: 1) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/#{form_id}/pages/2", headers, page.to_json, 200
        mock.put "/api/v1/forms/#{form_id}/pages/2/up", post_headers, moved_page.to_json, 200
      end
    end

    describe "api" do
      it "calls the move endpoint through ActiveResource" do
        move_request = ActiveResource::Request.new(:put, "/api/v1/forms/#{form_id}/pages/2/up", {}, post_headers)
        page = described_class.find(page_id: 2, form_id:)
        described_class.move_page(page, :up)
        expect(ActiveResource::HttpMock.requests).to include move_request
      end
    end

    describe "database" do
      it "updates the page in the database" do
        page = described_class.find(page_id: 2, form_id:)

        expect {
          described_class.move_page(page, :up)
        }.to change { Page.find(2).position }.from(2).to(1)
      end

      context "when the page has routing conditions" do
        let(:routing_conditions) do
          [
            build(:condition, id: 1, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Red"),
            build(:condition, id: 2, routing_page_id: 2, check_page_id: 2, goto_page_id: nil, skip_to_end: true, answer_value: "Green"),
          ]
        end

        let(:page) { build(:page, id: 2, form_id:, position: 2, routing_conditions:) }
        let(:moved_page) { build(:page, id: 2, form_id:, position: 1, routing_conditions:) }

        it "does not raise an error" do
          page = described_class.find(page_id: 2, form_id:)

          expect {
            described_class.move_page(page, :up)
          }.not_to raise_error
        end
      end
    end
  end
end
