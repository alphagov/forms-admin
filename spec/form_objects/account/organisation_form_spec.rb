require "rails_helper"

describe Account::OrganisationForm do
  subject(:organisation_form) { described_class.new(user:) }

  let(:user) { create(:user, :with_no_org) }
  let(:organisation) { create(:organisation) }

  describe "validations" do
    it "is valid with a valid organisation_id" do
      organisation_form.organisation_id = organisation.id
      expect(organisation_form).to be_valid
    end

    it "is invalid without an organisation_id" do
      organisation_form.organisation_id = nil
      error_message = I18n.t("activemodel.errors.models.account/organisation_form.attributes.organisation_id.blank")
      expect(organisation_form).to be_invalid
      expect(organisation_form.errors[:organisation_id]).to include(error_message)
    end
  end

  describe "#submit" do
    context "with valid attributes" do
      before do
        organisation_form.organisation_id = organisation.id
      end

      it "updates the user organisation_id" do
        expect { organisation_form.submit }.to change { user.reload.organisation_id }.to(organisation.id)
      end

      it "returns true" do
        expect(organisation_form.submit).to be true
      end
    end

    context "with invalid attributes" do
      before do
        organisation_form.organisation_id = nil
      end

      it "does not update the user organisation_id" do
        expect { organisation_form.submit }.not_to(change { user.reload.organisation_id })
      end

      it "returns false" do
        expect(organisation_form.submit).to be false
      end
    end
  end

  describe "#assign_form_values" do
    let(:user) { create(:user) }

    it "assigns the user organisation_id to the form" do
      expect { organisation_form.assign_form_values }.to change(organisation_form, :organisation_id).to(user.organisation_id)
    end

    it "returns the form object" do
      expect(organisation_form.assign_form_values).to eq(organisation_form)
    end
  end
end
