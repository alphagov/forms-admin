require "rails_helper"

describe PageRepository do
  describe "#find" do
    let(:page) { build(:page, id: 2, form_id: 1) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages/2", headers, page.to_json, 200
      end
    end

    it "finds the page through ActiveResource" do
      described_class.find(page_id: page.id, form_id: 1)
      expect(Page.new(id: 2, form_id: 1)).to have_been_read
    end
  end

  describe "#create!" do
    let(:page_params) do
      { question_text: "asdf",
        hint_text: "",
        is_optional: false,
        is_repeatable: false,
        form_id: 1,
        answer_settings: {},
        page_heading: nil,
        guidance_markdown: nil,
        answer_type: "organisation_name" }
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms/1/pages", post_headers, Page.new(page_params).to_json, 200
      end
    end

    it "creates a page through ActiveResource" do
      described_class.create!(page_params)
      expect(Page.new(page_params)).to have_been_created
    end
  end

  describe "#save!" do
    let(:page) { build(:page, id: 2, form_id: 1, is_optional: false) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages/2", headers, page.to_json, 200
        mock.put "/api/v1/forms/1/pages/2", post_headers
      end
    end

    it "updates the page through ActiveResource" do
      page = described_class.find(page_id: 2, form_id: 1)
      page.is_optional = true
      described_class.save!(page)
      expect(Page.new(id: 2, form_id: 1, is_optional: true)).to have_been_updated
    end
  end

  describe "#destroy" do
    let(:page) { build(:page, id: 2, form_id: 1) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages/2", headers, page.to_json, 200
        mock.delete "/api/v1/forms/1/pages/2", delete_headers, nil, 204
      end
    end

    it "destroys the page through ActiveResource" do
      page = described_class.find(page_id: 2, form_id: 1)
      described_class.destroy(page)
      expect(Page.new(id: 2, form_id: 1)).to have_been_deleted
    end
  end

  describe "#move_page" do
    let(:page) { build(:page, id: 2, form_id: 1) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages/2", headers, page.to_json, 200
        mock.put "/api/v1/forms/1/pages/2/up", post_headers
      end
    end

    it "calls the move endpoint through ActiveResource" do
      move_request = ActiveResource::Request.new(:put, "/api/v1/forms/1/pages/2/up", {}, post_headers)
      page = described_class.find(page_id: 2, form_id: 1)
      described_class.move_page(page, :up)
      expect(ActiveResource::HttpMock.requests).to include move_request
    end
  end
end
