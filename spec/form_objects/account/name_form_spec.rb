require "rails_helper"

describe Account::NameForm do
  subject(:name_form) { described_class.new(user:) }

  let(:user) { create(:user) }

  describe "validations" do
    it "is valid with a name" do
      name_form.name = "Test user"
      expect(name_form).to be_valid
    end

    it "is invalid without a name" do
      name_form.name = ""
      error_message = I18n.t("activemodel.errors.models.account/name_form.attributes.name.blank")
      expect(name_form).not_to be_valid
      expect(name_form.errors[:name]).to include(error_message)
    end
  end

  describe "#submit" do
    context "with valid attributes" do
      before do
        name_form.name = "new name"
      end

      it "updates the user name" do
        expect { name_form.submit }.to change { user.reload.name }.to("new name")
      end

      it "returns true" do
        expect(name_form.submit).to be true
      end
    end

    context "with invalid params" do
      before do
        name_form.name = ""
      end

      it "does not update the user name" do
        expect { name_form.submit }.not_to(change { user.reload.name })
      end

      it "returns false" do
        expect(name_form.submit).to be false
      end
    end
  end

  describe "#assign_form_values" do
    it "assigns the user name to the form" do
      expect { name_form.assign_form_values }.to change(name_form, :name).to(user.name)
    end

    it "returns the form object" do
      expect(name_form.assign_form_values).to eq(name_form)
    end
  end
end
