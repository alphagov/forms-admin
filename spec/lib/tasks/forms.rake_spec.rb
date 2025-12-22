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

    let(:form) { create :form, :live, submission_type: "s3", submission_format: [] }
    let!(:other_form) { create :form, :live, submission_type: "s3", submission_format: [] }

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
      let(:form) { create :form, :live, submission_type: "s3", submission_format: %w[json] }

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
      let(:form) { create :form, :live, submission_type: "s3", submission_format: %w[json] }

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

  describe "add_value_to_selection_options" do
    subject(:task) do
      Rake::Task["forms:add_value_to_selection_options"]
        .tap(&:reenable)
    end

    let(:form) { create :form, pages: }
    let(:form_without_selection_options) { create :form, :with_pages }
    let(:pages) do
      [
        create(:page,
               :with_selection_settings,
               answer_settings: DataStruct.new(
                 only_one_option: "true",
                 selection_options: [{ name: "option 1" }, { name: "option 2" }],
               )),
        create(:page, :with_single_line_text_settings),
      ]
    end
    let(:draft_question) { create :selection_draft_question, selection_options: [{ name: "option 1" }, { name: "option 2" }] }

    it "adds value to the step with selection options" do
      expect {
        task.invoke
      }.to change { form.draft_form_document.reload.content.dig("steps", 0, "data", "answer_settings") }.to(
        { "only_one_option" => "true", # only_one_option doesn't change
          "selection_options" => [{ "name" => "option 1", "value" => "option 1" },
                                  { "name" => "option 2", "value" => "option 2" }] },
      )
    end

    it "does not add value to the step without selection options" do
      expect {
        task.invoke
      }.not_to(change { form.draft_form_document.reload.content.dig("steps", 1, "data", "answer_settings") })
    end

    it "does not change form documents without selection options" do
      expect {
        task.invoke
      }.not_to(change { form_without_selection_options.draft_form_document.reload.content["steps"] })
    end

    it "updates the pages with selection options" do
      expect {
        task.invoke
      }.to change { pages.first.reload.answer_settings.as_json }.to(
        { "only_one_option" => "true",
          "selection_options" => [{ "name" => "option 1", "value" => "option 1" },
                                  { "name" => "option 2", "value" => "option 2" }] },
      )
    end

    it "updates the draft questions with selection options" do
      expect {
        task.invoke
      }.to change { draft_question.reload.answer_settings.as_json }.to(
        { "only_one_option" => "true",
          "selection_options" => [{ "name" => "option 1", "value" => "option 1" },
                                  { "name" => "option 2", "value" => "option 2" }] },
      )
    end
  end
end
