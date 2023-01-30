require "rails_helper"

RSpec.describe Forms::SubmissionEmailForm, type: :model do
  let(:form) { build :form, id: 1, submission_email: "curent_value@gds.gov.uk" }

  let(:submission_email_form_with_user) do
    build :submission_email_form, :with_user,
          form:,
          temporary_submission_email: "test@test.gov.uk",
          confirmation_code: "123456",
          user_information: OpenStruct.new(name: "User", email: "user@gov.uk")
  end

  it "has a valid factory" do
    submission_email_form = build :submission_email_form
    expect(submission_email_form).to be_valid
  end

  describe "validations" do
    it "is invalid if not given an email address ending with .gov.uk" do
      submission_email_form = build :submission_email_form, temporary_submission_email: "a@example.org"
      expect(submission_email_form).to be_invalid
    end

    it "is invalid if not given an email address" do
      submission_email_form = build :submission_email_form, temporary_submission_email: nil
      expect(submission_email_form).to be_invalid
    end

    it "is invalid if email_code is in the wrong format" do
      submission_email_form = build :submission_email_form, email_code: "abcdef", confirmation_code: "abcdef"
      expect(submission_email_form).to be_invalid
    end

    it "is invalid if email_code does not match confirmation code" do
      submission_email_form = build :submission_email_form, email_code: "000000", confirmation_code: "123456"
      expect(submission_email_form).to be_invalid
    end
  end

  describe "#assign_form_values" do
    context "when FormSubmissionEmail does not exist for form" do
      it "sets temporary_submission_email to form submission_email" do
        submission_email_form = build :submission_email_form, form: form

        submission_email_form.assign_form_values
        expect(submission_email_form.temporary_submission_email).to eq("curent_value@gds.gov.uk")
      end
    end

    context "when FormSubmissionEmail exists for form" do
      it "sets temporary_submission_email and confirmation_code from model" do
        create :form_submission_email, form_id: form.id, temporary_submission_email: "test@test.gov.uk", confirmation_code: "654321"
        submission_email_form = build :submission_email_form, form: form

        submission_email_form.assign_form_values
        expect(submission_email_form.temporary_submission_email).to eq("test@test.gov.uk")
        expect(submission_email_form.confirmation_code).to eq("654321")
      end
    end
  end

  describe "#submit" do
    it "returns false if invalid" do
      submission_email_form = build :submission_email_form, temporary_submission_email: ""
      expect(submission_email_form.submit).to be_falsy
    end

    context "when FormSubmissionEmail does not exist for form" do
      it "creates a FormSubmissionEmail object with form_id" do
        delivery = double
        expect(delivery).to receive(:deliver_now).with(no_args)

        allow(submission_email_form_with_user).to receive(:generate_confirmation_code).and_return("123456")

        allow(SubmissionEmailMailer).to receive(:confirmation_code_email)
                                          .with(
                                            new_submission_email: submission_email_form_with_user.temporary_submission_email,
                                            form_name: form.name,
                                            confirmation_code: submission_email_form_with_user.confirmation_code,
                                            notify_response_id: submission_email_form_with_user.notify_response_id,
                                            user_information: submission_email_form_with_user.user_information,
                                          ).and_return(delivery)

        result = submission_email_form_with_user.submit
        expect(result).to be_truthy
        form_submission_email = FormSubmissionEmail.find_by_form_id(1)
        expect(form_submission_email).to be_present
        expect(form_submission_email.temporary_submission_email).to eq("test@test.gov.uk")
        expect(form_submission_email.confirmation_code).not_to be_nil
        expect(form_submission_email.created_by_name).to eq("User")
        expect(form_submission_email.created_by_email).to eq("user@gov.uk")
      end
    end

    context "when FormSubmissionEmail does exist for form" do
      it "updates a FormSubmissionEmail object with form_id" do
        create :form_submission_email, form_id: form.id

        delivery = double
        expect(delivery).to receive(:deliver_now).with(no_args)

        allow(submission_email_form_with_user).to receive(:generate_confirmation_code).and_return("123456")

        allow(SubmissionEmailMailer).to receive(:confirmation_code_email)
                                          .with(
                                            new_submission_email: submission_email_form_with_user.temporary_submission_email,
                                            form_name: form.name,
                                            confirmation_code: submission_email_form_with_user.confirmation_code,
                                            notify_response_id: submission_email_form_with_user.notify_response_id,
                                            user_information: submission_email_form_with_user.user_information,
                                          ).and_return(delivery)

        result = submission_email_form_with_user.submit
        expect(result).to be_truthy
        form_submission_email = FormSubmissionEmail.find_by_form_id(1)
        expect(form_submission_email).to be_present
        expect(form_submission_email.temporary_submission_email).to eq("test@test.gov.uk")
        expect(form_submission_email.confirmation_code).not_to be_nil
        expect(form_submission_email.updated_by_name).to eq("User")
        expect(form_submission_email.updated_by_email).to eq("user@gov.uk")
      end
    end
  end

  describe "#confirm_confirmation_code" do
    it "returns false if invalid" do
      submission_email_form = build :submission_email_form, temporary_submission_email: ""
      expect(submission_email_form.confirm_confirmation_code).to be_falsy
    end

    it "returns false and does not update form if confirmation code does not match" do
      allow(form).to receive(:save!).and_return(true)
      create :form_submission_email, form_id: form.id, confirmation_code: "654321"
      submission_email_form = build :submission_email_form, :with_user, form: form, temporary_submission_email: "test@test.gov.uk", email_code: "123456"
      submission_email_form.assign_form_values
      expect(submission_email_form.confirm_confirmation_code).to be_falsy
      # Returns form's submission email is unchanged
      expect(form.submission_email).to eq("curent_value@gds.gov.uk")
    end

    it "returns true and updates form if confirmation code does not match" do
      allow(form).to receive(:save!).and_return(true)
      create :form_submission_email, form_id: form.id, confirmation_code: "123456", temporary_submission_email: "test@test.gov.uk"

      submission_email_form_with_user.assign_form_values
      # Returns true and updates the form's submission email
      expect(submission_email_form_with_user.confirm_confirmation_code).to be_truthy
      expect(form.submission_email).to eq("test@test.gov.uk")

      # updates the FormSubmissionEmail to show cleared
      expect(FormSubmissionEmail.find_by_form_id(form.id).confirmation_code).to be_nil
      expect(FormSubmissionEmail.find_by_form_id(form.id).updated_by_name).not_to be_nil
      expect(FormSubmissionEmail.find_by_form_id(form.id).updated_by_email).not_to be_nil
    end

    context "when FormSubmissionEmail does not exist for form" do
      it "creates a FormSubmissionEmail object with form_id" do
        delivery = double
        expect(delivery).to receive(:deliver_now).with(no_args)

        allow(submission_email_form_with_user).to receive(:generate_confirmation_code).and_return("123456")

        allow(SubmissionEmailMailer).to receive(:confirmation_code_email)
                                          .with(
                                            new_submission_email: submission_email_form_with_user.temporary_submission_email,
                                            form_name: form.name,
                                            confirmation_code: submission_email_form_with_user.confirmation_code,
                                            notify_response_id: submission_email_form_with_user.notify_response_id,
                                            user_information: submission_email_form_with_user.user_information,
                                          ).and_return(delivery)

        result = submission_email_form_with_user.submit
        expect(result).to be_truthy
        form_submission_email = FormSubmissionEmail.find_by_form_id(1)
        expect(form_submission_email).to be_present
        expect(form_submission_email.temporary_submission_email).to eq("test@test.gov.uk")
        expect(form_submission_email.confirmation_code).not_to be_nil
        expect(form_submission_email.created_by_name).to eq("User")
        expect(form_submission_email.created_by_email).to eq("user@gov.uk")
      end
    end

    context "when FormSubmissionEmail does exist for form" do
      it "updates a FormSubmissionEmail object with form_id" do
        create :form_submission_email, form_id: form.id
        delivery = double
        expect(delivery).to receive(:deliver_now).with(no_args)

        allow(submission_email_form_with_user).to receive(:generate_confirmation_code).and_return("123456")

        allow(SubmissionEmailMailer).to receive(:confirmation_code_email)
                                          .with(
                                            new_submission_email: submission_email_form_with_user.temporary_submission_email,
                                            form_name: form.name,
                                            confirmation_code: submission_email_form_with_user.confirmation_code,
                                            notify_response_id: submission_email_form_with_user.notify_response_id,
                                            user_information: submission_email_form_with_user.user_information,
                                          ).and_return(delivery)

        result = submission_email_form_with_user.submit
        expect(result).to be_truthy
        form_submission_email = FormSubmissionEmail.find_by_form_id(1)
        expect(form_submission_email).to be_present
        expect(form_submission_email.temporary_submission_email).to eq("test@test.gov.uk")
        expect(form_submission_email.confirmation_code).not_to be_nil
        expect(form_submission_email.updated_by_name).to eq("User")
        expect(form_submission_email.updated_by_email).to eq("user@gov.uk")
      end
    end
  end
end
