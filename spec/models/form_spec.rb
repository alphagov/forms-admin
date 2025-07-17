require "rails_helper"

RSpec.describe Form, type: :model do
  subject(:form) { described_class.new }

  it "has a valid factory" do
    form = create :form_record
    expect(form).to be_valid
  end

  describe "external_id" do
    it "intialises a new form with an external id matching its id" do
      form = create :form_record
      expect(form.external_id).to eq(form.id.to_s)
    end
  end

  describe "page scope" do
    it "returns pages in position order" do
      form = create :form_record

      page_a = create :page_record, form_id: form.id, position: 2
      page_b = create :page_record, form_id: form.id, position: 1

      expect(form.pages).to eq([page_b, page_a])
    end
  end

  describe "submission type" do
    describe "enum" do
      it "returns a list of submission types" do
        expect(described_class.submission_types.keys).to eq(%w[email email_with_csv s3])
        expect(described_class.submission_types.values).to eq(%w[email email_with_csv s3])
      end
    end
  end
end
