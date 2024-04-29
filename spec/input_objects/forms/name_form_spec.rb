require "rails_helper"

RSpec.describe Forms::NameForm, type: :model do
  describe "name" do
    it "is invalid if blank" do
      name_form = described_class.new(name: "")
      error_message = I18n.t("activemodel.errors.models.forms/name_form.attributes.name.blank")

      name_form.validate(:name)

      expect(name_form.errors.full_messages_for(:name)).to eq(
        ["Name #{error_message}"],
      )
    end
  end

  describe "#submit" do
    context "with valid attributes" do
      it "saves the form" do
        form = build :form
        name_form = described_class.new(form:, name: "New Form")

        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms", post_headers, { id: 1, name: "New Form" }.to_json, 200
        end

        expect {
          name_form.submit
        }.to change(form, :name).to("New Form")

        expect(form).to be_persisted
      end
    end

    context "with invalid attributes" do
      it "does not save the form" do
        form = build :form
        name_form = described_class.new(form:, name: "")

        expect {
          name_form.submit
        }.not_to change(form, :name)

        expect(form).not_to be_persisted
      end
    end
  end
end
