require "rails_helper"

describe FormRepository do
  describe "#create!" do
    let(:form_params) { { creator_id: 1, name: "asdf" } }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms", post_headers, Api::V1::FormResource.new(form_params).to_json, 200
      end
    end

    it "creates a form through ActiveResource" do
      described_class.create!(**form_params)
      expect(Api::V1::FormResource.new(form_params)).to have_been_created
    end
  end

  describe "#find" do
    let(:form) { build(:form, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
      end
    end

    it "finds the form through ActiveResource" do
      described_class.find(form_id: 2)
      expect(Api::V1::FormResource.new(id: 2)).to have_been_read
    end
  end

  describe "#find_live" do
    let(:form) { build(:form, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2/live", headers, form.to_json, 200
      end
    end

    it "calls the find_live endpoint through ActiveResource" do
      find_live_request = ActiveResource::Request.new(:get, "/api/v1/forms/2/live", form, headers)
      described_class.find_live(form_id: 2)
      expect(ActiveResource::HttpMock.requests).to include find_live_request
    end
  end

  describe "#find_archived" do
    let(:form) { build(:form, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2/archived", headers, form.to_json, 200
      end
    end

    it "calls the find_archived endpoint through ActiveResource" do
      find_archived_request = ActiveResource::Request.new(:get, "/api/v1/forms/2/archived", form, headers)
      described_class.find_archived(form_id: 2)
      expect(ActiveResource::HttpMock.requests).to include find_archived_request
    end
  end

  describe "#where" do
    let(:form) { build(:form, id: 2, creator_id: 3) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?creator_id=3", headers, [form].to_json, 200
      end
    end

    it "calls the where endpoint through ActiveResource" do
      where_request = ActiveResource::Request.new(:get, "/api/v1/forms?creator_id=3", [form], headers)
      described_class.where(creator_id: 3)
      expect(ActiveResource::HttpMock.requests).to include where_request
    end
  end

  describe "#save!" do
    let(:form) { build(:form, id: 2, name: "original name") }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.put "/api/v1/forms/2", post_headers
      end
    end

    it "updates the form through ActiveResource" do
      form = described_class.find(form_id: 2)
      form.name = "new name"
      described_class.save!(form)
      expect(Api::V1::FormResource.new(id: 2, name: "new name")).to have_been_updated
    end
  end

  describe "#make_live!" do
    let(:form) { build(:form, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms/2/make-live", post_headers, form.to_json, 200
      end
    end

    it "calls the make-live endpoint through ActiveResource" do
      make_live_request = ActiveResource::Request.new(:post, "/api/v1/forms/2/make-live", {}, post_headers)
      described_class.make_live!(form)
      expect(ActiveResource::HttpMock.requests).to include make_live_request
    end
  end

  describe "#archive!" do
    let(:form) { build(:form, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms/2/archive", post_headers, form.to_json, 200
      end
    end

    it "calls the archive endpoint through ActiveResource" do
      archive_request = ActiveResource::Request.new(:post, "/api/v1/forms/2/archive", {}, post_headers)
      described_class.archive!(form)
      expect(ActiveResource::HttpMock.requests).to include archive_request
    end
  end

  describe "#destroy" do
    let(:form) { build(:form, id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.delete "/api/v1/forms/2", delete_headers, nil, 204
      end
    end

    it "destroys the form through ActiveResource" do
      form = described_class.find(form_id: 2)
      described_class.destroy(form)
      expect(Api::V1::FormResource.new(id: 2)).to have_been_deleted
    end
  end

  describe "#pages" do
    let(:form) { build(:form, id: 2) }
    let(:pages) { build_list(:page, 5) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
      end
    end

    it "gets a form's pages through ActiveResource" do
      pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2/pages", pages, headers)
      described_class.pages(form)
      expect(ActiveResource::HttpMock.requests).to include pages_request
    end
  end
end
