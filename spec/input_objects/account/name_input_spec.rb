require "rails_helper"

describe Account::NameInput do
  subject(:name_input) { described_class.new(user:) }

  let(:user) { create(:user) }

  describe "validations" do
    it "is valid with a name" do
      name_input.name = "Test user"
      expect(name_input).to be_valid
    end

    it "is invalid without a name" do
      name_input.name = ""
      error_message = I18n.t("activemodel.errors.models.account/name_input.attributes.name.blank")
      expect(name_input).not_to be_valid
      expect(name_input.errors[:name]).to include(error_message)
    end
  end

  describe "#submit" do
    context "with valid attributes" do
      before do
        name_input.name = "new name"
      end

      it "updates the user name" do
        expect { name_input.submit }.to change { user.reload.name }.to("new name")
      end

      it "returns true" do
        expect(name_input.submit).to be true
      end
    end

    context "with invalid params" do
      before do
        name_input.name = ""
      end

      it "does not update the user name" do
        expect { name_input.submit }.not_to(change { user.reload.name })
      end

      it "returns false" do
        expect(name_input.submit).to be false
      end
    end
  end

  describe "#assign_form_values" do
    it "assigns the user name to the form" do
      expect { name_input.assign_form_values }.to change(name_input, :name).to(user.name)
    end

    it "returns the form object" do
      expect(name_input.assign_form_values).to eq(name_input)
    end
  end
end
