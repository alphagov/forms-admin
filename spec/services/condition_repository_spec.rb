require "rails_helper"

describe ConditionRepository do
  describe "#create!" do
    let(:condition_params) do
      { form_id: 1,
        page_id: 2,
        check_page_id: 2,
        routing_page_id: 2,
        answer_value: "Yes",
        goto_page_id: 3,
        skip_to_end: false }
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms/1/pages/2/conditions", post_headers, { id: 4 }.to_json, 200
      end
    end

    it "creates a condition through ActiveResource" do
      described_class.create!(**condition_params)
      expect(Condition.new(**condition_params)).to have_been_created
    end
  end

  describe "#find" do
    let(:condition) { build(:condition, id: 4, form_id: 1, page_id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages/2/conditions/#{condition.id}", headers, condition.to_json, 200
      end
    end

    it "finds the condition through ActiveResource" do
      described_class.find(condition_id: condition.id, form_id: 1, page_id: 2)
      expect(Condition.new(id: 4, form_id: 1, page_id: 2)).to have_been_read
    end
  end

  describe "#save!" do
    let(:condition) { build(:condition, id: 4, skip_to_end: false, form_id: 1, page_id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages/2/conditions/4", headers, condition.to_json, 200
        mock.put "/api/v1/forms/1/pages/2/conditions/4", post_headers
      end
    end

    it "updates the condition through ActiveResource" do
      condition = described_class.find(condition_id: 4, form_id: 1, page_id: 2)
      condition.skip_to_end = true
      described_class.save!(condition)
      expect(Condition.new(id: 4, skip_to_end: true, form_id: 1, page_id: 2)).to have_been_updated
    end
  end

  describe "#destroy" do
    let(:condition) { build(:condition, id: 4, form_id: 1, page_id: 2) }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages/2/conditions/4", headers, condition.to_json, 200
        mock.delete "/api/v1/forms/1/pages/2/conditions/4", delete_headers, nil, 204
      end
    end

    it "destroys the condition through ActiveResource" do
      condition = described_class.find(condition_id: 4, form_id: 1, page_id: 2)
      described_class.destroy(condition)
      expect(Condition.new(id: 4, form_id: 1, page_id: 2)).to have_been_deleted
    end
  end
end
