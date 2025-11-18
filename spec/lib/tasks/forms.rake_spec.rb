require "rake"
require "rails_helper"

RSpec.describe "forms.rake" do
  before do
    Rake.application.rake_require "tasks/forms"
    Rake::Task.define_task(:environment)
  end

  describe "forms:move" do
    subject(:task) do
      Rake::Task["forms:move"]
        .tap(&:reenable)
    end

    let(:group) { create :group }
    let(:forms) { create_list(:form, 3) }
    let(:form_ids) { forms.map(&:id) }

    context "with valid arguments" do
      context "with a single form not in a group" do
        let(:form_id) { form_ids.first }
        let(:valid_args) { [form_id, group.external_id] }

        it "adds the form to the group" do
          expect {
            task.invoke(*valid_args)
          }.to change(GroupForm, :count).by(1)

          expect(GroupForm.last).to eq(GroupForm.new(form_id:, group:))
        end
      end

      context "with a single form already in a group" do
        let(:form_id) { form_ids.first }
        let(:old_group) { create :group }
        let(:valid_args) { [form_id, group.external_id] }

        before do
          GroupForm.create! form_id:, group: old_group
        end

        it "adds the form to the group" do
          expect {
            task.invoke(*valid_args)
          }.not_to change(GroupForm, :count)

          expect(GroupForm.find_by(form_id:))
            .to eq(GroupForm.new(form_id:, group:))
        end
      end

      context "with a single form already in the target group" do
        let(:form_id) { form_ids.first }
        let(:valid_args) { [form_id, group.external_id] }

        before do
          GroupForm.create! form_id:, group:
        end

        it "keeps the form in the group" do
          expect {
            task.invoke(*valid_args)
          }.not_to change(GroupForm, :count)

          expect(GroupForm.find_by(form_id:))
            .to eq(GroupForm.new(form_id:, group:))
        end
      end

      context "with a multiple forms" do
        let(:valid_args) { [*form_ids, group.external_id] }

        it "adds each form to the group" do
          task.invoke(*valid_args)

          form_ids.each do |form_id|
            expect(GroupForm.find_by(form_id:))
              .to eq(GroupForm.new(form_id:, group:))
          end
        end
      end
    end

    context "with invalid arguments" do
      shared_examples_for "usage error" do
        it "aborts with a usage message" do
          expect {
            task.invoke(*invalid_args)
          }.to raise_error(SystemExit)
                 .and output(/usage: rake forms:move/).to_stderr
        end
      end

      context "with no arguments" do
        it_behaves_like "usage error" do
          let(:invalid_args) { [] }
        end
      end

      context "with only one argument" do
        it_behaves_like "usage error" do
          let(:invalid_args) { [form_ids.first] }
        end
      end

      context "with invalid group_id" do
        let(:invalid_args) { [*form_ids, "not_a_group_id"] }

        it "raises an error" do
          expect {
            task.invoke(*invalid_args)
          }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Group/)
        end
      end

      context "with invalid form_id" do
        let(:invalid_args) { ["99", group.external_id] }

        it "raises an error" do
          expect {
            task.invoke(*invalid_args)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe "forms:submission_email:update" do
    subject(:task) do
      Rake::Task["forms:submission_email:update"]
        .tap(&:reenable)
    end

    let(:form) do
      create :form
    end

    context "with valid arguments" do
      let(:submission_email) { "test@example.gov.uk" }
      let(:valid_args) { [form.id, submission_email] }

      shared_examples "submission email update" do
        it "changes the form submission email" do
          expect {
            task.invoke(*valid_args)
          }.to change { form.reload.submission_email }.to(submission_email)
        end

        it "updates the email confirmation status" do
          task.invoke(*valid_args)
          expect(form.reload.email_confirmation_status).to eq(:email_set_without_confirmation)
        end
      end

      include_examples "submission email update"

      context "when the form has a submission email record" do
        include_examples "submission email update"

        it "is deleted" do
          form_submission_email = FormSubmissionEmail.create!(form_id: form.id)

          expect {
            task.invoke(*valid_args)
          }.to change(FormSubmissionEmail, :count).by(-1)

          expect {
            form_submission_email.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the submission email is not a government email address" do
        let(:submission_email) { "test@example.aws.com" }

        include_examples "submission email update"

        it "does not raise a validation error" do
          expect {
            task.invoke(*valid_args)
          }.not_to raise_error
        end
      end
    end

    context "with invalid arguments" do
      shared_examples_for "usage error" do
        it "aborts with a usage message" do
          expect {
            task.invoke(*invalid_args)
          }.to raise_error(SystemExit)
                 .and output(/usage: rake forms:submission_email:update/).to_stderr
        end
      end

      context "with no arguments" do
        it_behaves_like "usage error" do
          let(:invalid_args) { [] }
        end
      end

      context "with only one argument" do
        it_behaves_like "usage error" do
          let(:invalid_args) { [form.id] }
        end
      end

      context "with invalid form_id" do
        let(:invalid_args) { ["99", "test@example.com"] }

        it "raises an error" do
          expect {
            task.invoke(*invalid_args)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with invalid email address" do
        let(:invalid_args) { %w[99 not_an_email_address] }

        it "raises an error" do
          expect {
            task.invoke(*invalid_args)
          }.to raise_error(/not an email address/)
        end
      end
    end
  end

  describe "forms:submission_type:set_to_email" do
    subject(:task) do
      Rake::Task["forms:submission_type:set_to_email"]
        .tap(&:reenable)
    end

    let(:form) { create :form, :live, submission_type: "s3", submission_format: nil }
    let!(:other_form) { create :form, :live, submission_type: "s3", submission_format: nil }

    context "when the form is live" do
      it "sets a form's submission_type to email" do
        expect { task.invoke(form.id) }
          .to change { form.reload.submission_type }.to("email")
      end

      it "updates a form's live form document" do
        task.invoke(form.id)
        expect(form.live_form_document.reload.content["submission_type"]).to eq("email")
        expect(form.live_form_document.reload.content["submission_format"]).to eq([])
      end

      it "updates the form's draft form document" do
        task.invoke(form.id)
        expect(form.draft_form_document.reload.content["submission_type"]).to eq("email")
        expect(form.live_form_document.reload.content["submission_format"]).to eq([])
      end

      it "does not update a different form" do
        expect { task.invoke(form.id) }
          .not_to(change { other_form.reload.submission_type })
      end
    end

    context "when the form is draft" do
      let(:form) { create :form, submission_type: "s3" }

      it "sets a form's submission_type to email" do
        expect { task.invoke(form.id) }
          .to change { form.reload.submission_type }.to("email")
      end

      it "updates the form's draft form document" do
        task.invoke(form.id)
        expect(form.draft_form_document.reload.content["submission_type"]).to eq("email")
        expect(form.draft_form_document.reload.content["submission_format"]).to eq([])
      end
    end

    context "when the provided submission format is empty" do
      it "sets a form's submission format to empty" do
        expect { task.invoke(form.id) }
          .to change { form.reload.submission_format }.to([])
      end

      it "sets a form's submission_type to email" do
        expect { task.invoke(form.id) }
          .to change { form.reload.submission_type }.to("email")
      end
    end

    context "when the provided submission format is email" do
      it "sets a form's submission format to empty" do
        expect { task.invoke(form.id, "email") }
          .to change { form.reload.submission_format }.to([])
      end

      it "sets a form's submission_type to email" do
        expect { task.invoke(form.id, "email") }
          .to change { form.reload.submission_type }.to("email")
      end
    end

    context "when the provided submission format is csv" do
      it "sets a form's submission format to csv" do
        expect { task.invoke(form.id, "csv") }
          .to change { form.reload.submission_format }.to(%w[csv])
      end

      it "sets a form's submission_type to email" do
        expect { task.invoke(form.id, "csv") }
          .to change { form.reload.submission_type }.to("email")
      end
    end

    context "when the provided submission formate is json" do
      it "sets a form's submission format to json" do
        expect { task.invoke(form.id, "json") }
          .to change { form.reload.submission_format }.to(%w[json])
      end

      it "sets a form's submission_type to email" do
        expect { task.invoke(form.id, "json") }
          .to change { form.reload.submission_type }.to("email")
      end
    end

    context "when the provided submission format is csv, json" do
      it "sets a form's submission format to csv and json" do
        expect { task.invoke(form.id, "csv", "json") }
          .to change { form.reload.submission_format }.to(%w[csv json])
      end

      it "sets a form's submission_type to email" do
        expect { task.invoke(form.id, "csv", "json") }
          .to change { form.reload.submission_type }.to("email")
      end
    end

    context "when the provided submission_type is s3" do
      it "aborts with a usage message" do
        expect { task.invoke(form.id, "s3") }
          .to raise_error(SystemExit)
                .and output("submission_format must be one of csv, json\n").to_stderr
      end
    end

    context "without arguments" do
      it "aborts with a usage message" do
        expect {
          task.invoke
        }.to raise_error(SystemExit)
               .and output("usage: rake forms:submission_type:set_to_email[<form_id>(, <submission_format>)*]\n").to_stderr
      end
    end
  end

  describe "forms:submission_type:set_to_s3" do
    subject(:task) do
      Rake::Task["forms:submission_type:set_to_s3"]
        .tap(&:reenable)
    end

    let(:form) { create :form, :live }
    let!(:other_form) { create :form, :live }
    let(:s3_bucket_name) { "a-bucket" }
    let(:s3_bucket_aws_account_id) { "an-aws-account-id" }
    let(:s3_bucket_region) { "eu-west-1" }
    let(:format) { "csv" }
    let(:valid_args) { [form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region, format] }

    context "when the form is live" do
      context "when the format is csv" do
        it "sets a form's submission_type to s3" do
          expect { task.invoke(*valid_args) }
            .to change { form.reload.submission_type }.to("s3")
        end

        it "sets a form's submission_format to csv" do
          expect { task.invoke(*valid_args) }
            .to change { form.reload.submission_format }.to(%w[csv])
        end

        it "updates the live form document" do
          task.invoke(*valid_args)
          form_document = form.live_form_document.reload
          expect(form_document.content["submission_type"]).to eq("s3")
          expect(form_document.content["submission_format"]).to eq(%w[csv])
          expect(form_document.content["s3_bucket_name"]).to eq(s3_bucket_name)
          expect(form_document.content["s3_bucket_aws_account_id"]).to eq(s3_bucket_aws_account_id)
          expect(form_document.content["s3_bucket_region"]).to eq(s3_bucket_region)
        end

        it "updates the draft form document" do
          task.invoke(*valid_args)
          form_document = form.draft_form_document.reload
          expect(form_document.content["submission_type"]).to eq("s3")
          expect(form_document.content["submission_format"]).to eq(%w[csv])
          expect(form_document.content["s3_bucket_name"]).to eq(s3_bucket_name)
          expect(form_document.content["s3_bucket_aws_account_id"]).to eq(s3_bucket_aws_account_id)
          expect(form_document.content["s3_bucket_region"]).to eq(s3_bucket_region)
        end
      end

      context "when the format is json" do
        let(:format) { "json" }

        it "sets a form's submission_type to s3" do
          expect { task.invoke(*valid_args) }
            .to change { form.reload.submission_type }.to("s3")
        end

        it "sets a form's submission_format to json" do
          expect { task.invoke(*valid_args) }
            .to change { form.reload.submission_format }.to(%w[json])
        end

        it "updates the live form document" do
          task.invoke(*valid_args)
          form_document = form.live_form_document.reload
          expect(form_document.content["submission_type"]).to eq("s3")
          expect(form_document.content["submission_format"]).to eq(%w[json])
        end

        it "updates the draft form document" do
          task.invoke(*valid_args)
          form_document = form.draft_form_document.reload
          expect(form_document.content["submission_type"]).to eq("s3")
          expect(form_document.content["submission_format"]).to eq(%w[json])
        end
      end

      it "sets a form's s3_bucket_name" do
        expect { task.invoke(*valid_args) }
          .to change { form.reload.s3_bucket_name }.to(s3_bucket_name)
      end

      it "sets a form's s3_bucket_aws_account_id" do
        expect { task.invoke(*valid_args) }
          .to change { form.reload.s3_bucket_aws_account_id }.to(s3_bucket_aws_account_id)
      end

      it "sets a form's s3_bucket_region" do
        expect { task.invoke(*valid_args) }
          .to change { form.reload.s3_bucket_region }.to(s3_bucket_region)
      end

      it "does not update a different form" do
        expect { task.invoke(*valid_args) }
          .not_to(change { other_form.reload.submission_type })
      end
    end

    context "when the form is draft" do
      let(:form) { create :form }

      it "sets a form's submission_type to s3" do
        expect { task.invoke(*valid_args) }
          .to change { form.reload.submission_type }.to("s3")
      end

      it "sets a form's submission_format" do
        expect { task.invoke(*valid_args) }
          .to change { form.reload.submission_format }.to([format])
      end

      it "updates the draft form document" do
        task.invoke(*valid_args)
        form_document = form.draft_form_document.reload
        expect(form_document.content["submission_type"]).to eq("s3")
        expect(form_document.content["submission_format"]).to eq([format])
        expect(form_document.content["s3_bucket_name"]).to eq(s3_bucket_name)
        expect(form_document.content["s3_bucket_aws_account_id"]).to eq(s3_bucket_aws_account_id)
        expect(form_document.content["s3_bucket_region"]).to eq(s3_bucket_region)
      end
    end

    context "without arguments" do
      it "aborts with a usage message" do
        expect {
          task.invoke
        }.to raise_error(SystemExit)
               .and output("usage: rake forms:submission_type:set_to_s3[<form_id>, <s3_bucket_name>, <s3_bucket_aws_account_id>, <s3_bucket_region>, <format>]\n").to_stderr
      end
    end

    context "without bucket name argument" do
      it "aborts with a usage message" do
        expect {
          task.invoke(1)
        }.to raise_error(SystemExit)
               .and output("usage: rake forms:submission_type:set_to_s3[<form_id>, <s3_bucket_name>, <s3_bucket_aws_account_id>, <s3_bucket_region>, <format>]\n").to_stderr
      end
    end

    context "without AWS account ID argument" do
      it "aborts with a usage message" do
        expect {
          task.invoke(1, s3_bucket_name)
        }.to raise_error(SystemExit)
               .and output("usage: rake forms:submission_type:set_to_s3[<form_id>, <s3_bucket_name>, <s3_bucket_aws_account_id>, <s3_bucket_region>, <format>]\n").to_stderr
      end
    end

    context "without region argument" do
      it "aborts with a usage message" do
        expect {
          task.invoke(1, s3_bucket_name, s3_bucket_aws_account_id)
        }.to raise_error(SystemExit)
               .and output("usage: rake forms:submission_type:set_to_s3[<form_id>, <s3_bucket_name>, <s3_bucket_aws_account_id>, <s3_bucket_region>, <format>]\n").to_stderr
      end
    end

    context "without format argument" do
      it "aborts with a usage message" do
        expect {
          task.invoke(1, s3_bucket_name, s3_bucket_aws_account_id, "eu-west-2")
        }.to raise_error(SystemExit)
               .and output("usage: rake forms:submission_type:set_to_s3[<form_id>, <s3_bucket_name>, <s3_bucket_aws_account_id>, <s3_bucket_region>, <format>]\n").to_stderr
      end
    end

    context "when region is not allowed" do
      it "aborts with message" do
        expect {
          task.invoke(1, s3_bucket_name, s3_bucket_aws_account_id, "eu-west-3", "csv")
        }.to raise_error(SystemExit)
               .and output("s3_bucket_region must be one of eu-west-1 or eu-west-2\n").to_stderr
      end
    end

    context "when format is invalid" do
      it "aborts with a usage message" do
        expect {
          task.invoke(1, s3_bucket_name, s3_bucket_aws_account_id, "eu-west-2", "xml")
        }.to raise_error(SystemExit)
                       .and output("format must be one of csv or json\n").to_stderr
      end
    end
  end

  describe "#check_submission_emails" do
    subject(:task) do
      Rake::Task["forms:check_submission_emails"].tap(&:reenable)
    end

    let!(:form_with_bad_submission_email) do
      form = build(:form, submission_email: "submission_email@")
      form.save!(validate: false)
      form
    end

    let!(:form_another_with_bad_submission_email) do
      form = build(:form, submission_email: "@invalid.gov.uk")
      form.save!(validate: false)
      form
    end

    let!(:form_with_bad_support_email) do
      form = build(:form, support_email: "invalid_support_email@")
      form.save!(validate: false)
      form
    end

    let!(:form_with_two_bad_emails) do
      form = build(:form, submission_email: "invalid_submission_email@.", support_email: "invalid_support_email@.")
      form.save!(validate: false)
      form
    end

    before do
      # these forms are vaild so we don't need to reference them in the tests
      create_list(:form, 2, support_email: "valid@email.gov.uk", submission_email: "submission_email@valid.gov.uk")
      create(:form, submission_email: nil, support_email: nil)

      allow(Rails.logger).to receive(:info)
      task.invoke
    end

    it "logs the start message" do
      expect(Rails.logger).to have_received(:info).with("Checking submission emails and support emails")
    end

    it "logs invalid submission emails" do
      expect(Rails.logger).to have_received(:info).with("Form #{form_with_bad_submission_email.id} submission_email 'submission_email@' is not a valid email address")
      expect(Rails.logger).to have_received(:info).with("Form #{form_another_with_bad_submission_email.id} submission_email '@invalid.gov.uk' is not a valid email address")
    end

    it "logs invalid support emails" do
      expect(Rails.logger).to have_received(:info).with("Form #{form_with_bad_support_email.id} support_email 'invalid_support_email@' is not a valid email address")
    end

    it "logs forms with multiple invalid emails" do
      expect(Rails.logger).to have_received(:info).with("Form #{form_with_two_bad_emails.id} submission_email 'invalid_submission_email@.' is not a valid email address")
      expect(Rails.logger).to have_received(:info).with("Form #{form_with_two_bad_emails.id} support_email 'invalid_support_email@.' is not a valid email address")
    end

    it "logs the completion summary with correct counts" do
      expect(Rails.logger).to have_received(:info).with("Invalid email check completed. There were 3 invalid submission emails and 2 invalid support emails")
    end
  end
end
