require "rails_helper"

RSpec.describe Forms::ContactDetailsForm, type: :model do
  it "has a valid factory" do
    contact_details_form = build :contact_details_form
    expect(contact_details_form).to be_valid
  end

  describe "validations" do
    describe "email" do
      context "when email is ticked" do
        it "is invalid if blank" do
          contact_details_form = build :contact_details_form, email: ""
          expect(contact_details_form).to be_invalid
        end

        it "is invalid if doesn't end with *.gov.uk" do
          error_message = I18n.t("activemodel.errors.models.forms/contact_details_form.attributes.email.non_govuk_email")
          contact_details_form = build :contact_details_form, email: "something@gmail.com"
          expect(contact_details_form).to be_invalid

          expect(contact_details_form.errors.full_messages_for(:email)).to include "Email #{error_message}"
        end

        it "is invalid if doesn't have an @ symbol in" do
          error_message = I18n.t("activemodel.errors.models.forms/contact_details_form.attributes.email.invalid_email")
          contact_details_form = build :contact_details_form, email: "something.something.gov.uk"
          expect(contact_details_form).to be_invalid

          expect(contact_details_form.errors.full_messages_for(:email)).to include "Email #{error_message}"
        end

        it "is valid if given an email with an @ and ending in .gov.uk" do
          contact_details_form = build :contact_details_form, email: "something@something.gov.uk"
          expect(contact_details_form).to be_valid
        end
      end

      context "when email is not ticked" do
        it "is valid even given an invalid email" do
          contact_details_form = build :contact_details_form, email: "invalid email value", contact_details_supplied: %w[supply_phone supply_link]
          expect(contact_details_form).to be_valid
        end
      end
    end

    describe "phone" do
      context "when phone is ticked" do
        it "is invalid if blank" do
          contact_details_form = build :contact_details_form, phone: ""
          expect(contact_details_form).to be_invalid
        end

        it "is valid if 500 characters" do
          contact_details_form = build :contact_details_form, phone: "x" * 500
          expect(contact_details_form).to be_valid
        end

        it "is invalid if 501 characters" do
          error_message = I18n.t("activemodel.errors.models.forms/contact_details_form.attributes.phone.too_long")
          contact_details_form = build :contact_details_form, phone: "x" * 501
          expect(contact_details_form).to be_invalid
          expect(contact_details_form.errors.full_messages_for(:phone)).to include "Phone #{error_message}"
        end
      end

      context "when phone is not ticked" do
        it "is valid even given invalid phone value" do
          contact_details_form = build :contact_details_form, phone: "", contact_details_supplied: %w[supply_email supply_link]
          expect(contact_details_form).to be_valid
        end
      end
    end

    describe "link" do
      context "when link is ticked" do
        describe "link_text" do
          it "link_text is invalid if blank" do
            error_message = I18n.t("activemodel.errors.models.forms/contact_details_form.attributes.link_text.blank")
            contact_details_form = build :contact_details_form, link_text: ""
            expect(contact_details_form).to be_invalid
            expect(contact_details_form.errors.full_messages_for(:link_text)).to include "Link text #{error_message}"
          end

          it "link_text is valid if 120 characters" do
            contact_details_form = build :contact_details_form, link_text: "https://example.org/".ljust(120, "x")
            expect(contact_details_form).to be_valid
          end

          it "link_text is invalid if 121 characters" do
            error_message = I18n.t("activemodel.errors.models.forms/contact_details_form.attributes.link_text.too_long")
            contact_details_form = build :contact_details_form, link_text: "https://example.org/".ljust(121, "x")
            expect(contact_details_form).to be_invalid
            expect(contact_details_form.errors.full_messages_for(:link_text)).to include "Link text #{error_message}"
          end
        end

        describe "link_href" do
          it "link_href is invalid if blank" do
            error_message = I18n.t("activemodel.errors.models.forms/contact_details_form.attributes.link_href.blank")
            contact_details_form = build :contact_details_form, link_href: ""
            expect(contact_details_form).to be_invalid
            expect(contact_details_form.errors.full_messages_for(:link_href)).to include "Link href #{error_message}"
          end

          it "link_href is valid if 120 characters" do
            contact_details_form = build :contact_details_form, link_href: "https://example.org/".ljust(120, "x")
            expect(contact_details_form).to be_valid
          end

          it "link_href is invalid if 121 characters" do
            error_message = I18n.t("activemodel.errors.models.forms/contact_details_form.attributes.link_href.too_long")
            contact_details_form = build :contact_details_form, link_href: "https://example.org/".ljust(121, "x")
            expect(contact_details_form).to be_invalid
            expect(contact_details_form.errors.full_messages_for(:link_href)).to include "Link href #{error_message}"
          end

          it "link_href is invalid if not a URL" do
            error_message = I18n.t("activemodel.errors.models.forms/contact_details_form.attributes.link_href.url")
            contact_details_form = build :contact_details_form, link_href: "not-url"
            expect(contact_details_form).to be_invalid
            expect(contact_details_form.errors.full_messages_for(:link_href)).to include "Link href #{error_message}"
          end

          it "link_href is valid if a URL" do
            contact_details_form = build :contact_details_form, link_href: "http://tests.org"
            expect(contact_details_form).to be_valid
          end
        end
      end

      context "when link is not ticked" do
        it "is valid even when link_text is invalid" do
          contact_details_form = build :contact_details_form, link_text: "", contact_details_supplied: %w[supply_email supply_phone]
          expect(contact_details_form).to be_valid
        end

        it "is valid even when link_href is invalid" do
          contact_details_form = build :contact_details_form, link_href: "", contact_details_supplied: %w[supply_email supply_phone]
          expect(contact_details_form).to be_valid
        end
      end
    end

    context "when nothing is ticked" do
      it "is invalid " do
        error_message = I18n.t("activemodel.errors.models.forms/contact_details_form.attributes.contact_details_supplied.must_be_supply_contact_details")
        contact_details_form = build :contact_details_form, contact_details_supplied: []
        expect(contact_details_form).to be_invalid
        expect(contact_details_form.errors.full_messages_for(:contact_details_supplied)).to include "Contact details supplied #{error_message}"
      end
    end
  end

  describe "#assign_form_values" do
    context "with all support details set" do
      subject(:contact_details_form) { described_class.new(form:) }

      let(:form) { build :form, :with_support }

      before do
        contact_details_form.assign_form_values
      end

      it "assigns email" do
        expect(contact_details_form.email).to eq(form.support_email)
      end

      it "assigns phone" do
        expect(contact_details_form.phone).to eq(form.support_phone)
      end

      it "assigns link_href" do
        expect(contact_details_form.link_href).to eq(form.support_url)
      end

      it "assigns link_text" do
        expect(contact_details_form.link_text).to eq(form.support_url_text)
      end

      it "returns self" do
        expect(contact_details_form.assign_form_values).to eq(contact_details_form)
      end

      it "contact_details_supplied contains correct values" do
        expect(contact_details_form.contact_details_supplied).to include(:supply_email)
      end
    end

    context "without support_email" do
      it "contact_details_supplied contains correct values" do
        form = build :form, :with_support, support_email: ""
        contact_details_form = described_class.new(form:)
        expect(contact_details_form.contact_details_supplied).not_to include(:supply_email)
      end
    end

    context "without support_phone" do
      it "contact_details_supplied does not contains supply_email" do
        form = build :form, :with_support, support_phone: ""
        contact_details_form = described_class.new(form:)
        expect(contact_details_form.contact_details_supplied).not_to include(:supply_email)
      end
    end

    context "without support_url" do
      it "contact_details_supplied contains correct values" do
        form = build :form, :with_support, support_url: ""
        contact_details_form = described_class.new(form:)
        expect(contact_details_form.contact_details_supplied).not_to include(:supply_link)
      end
    end
  end

  describe "#submit" do
    context "when invalid" do
      subject(:contact_details_form) { build :contact_details_form, contact_details_supplied: [] }

      before do
        allow(contact_details_form.form).to receive(:save!)
      end

      it "returns false" do
        expect(contact_details_form.submit).to eq false
      end

      it "does not save form" do
        contact_details_form.submit
        expect(contact_details_form.form).not_to have_received(:save!)
      end
    end

    context "when valid" do
      subject(:contact_details_form) { build :contact_details_form }

      before do
        allow(contact_details_form.form).to receive(:save!).and_return(true)
      end

      it "not be false" do
        expect(contact_details_form.submit).to eq(true)
      end

      it "saves the form" do
        contact_details_form.submit
        expect(contact_details_form.form).to have_received(:save!)
      end

      it "sets the form values" do
        contact_details_form.submit
        expect(contact_details_form.form.support_email).to eq(contact_details_form.email)
        expect(contact_details_form.form.support_phone).to eq(contact_details_form.phone)
        expect(contact_details_form.form.support_url).to eq(contact_details_form.link_href)
        expect(contact_details_form.form.support_url_text).to eq(contact_details_form.link_text)
      end
    end
  end
end
