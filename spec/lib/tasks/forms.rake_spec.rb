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
    let(:forms) do
      build_list(:form, 3) { |form, i| form.id = i }
    end
    let(:form_ids) { forms.map(&:id) }

    before do
      allow(FormRepository).to receive(:find).and_call_original
      forms.each do |form|
        allow(FormRepository).to receive(:find).with(form_id: form.id).and_return(form)
      end
    end

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
        context "when use_database_as_truth if false" do
          let(:invalid_args) { ["99", group.external_id] }

          before do
            allow(Settings).to receive(:use_database_as_truth).and_return(false)

            ActiveResource::HttpMock.respond_to do |mock|
              mock.get "/api/v1/forms/99", headers, nil, 404
            end
          end

          it "raises an error" do
            expect {
              task.invoke(*invalid_args)
            }.to raise_error(ActiveResource::ResourceNotFound)
          end
        end

        context "when use_database_as_truth if true" do
          let(:invalid_args) { ["99", group.external_id] }

          before do
            allow(Settings).to receive(:use_database_as_truth).and_return(true)
          end

          it "raises an error" do
            expect {
              task.invoke(*invalid_args)
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
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

      before do
        allow(FormRepository).to receive_messages(find: form, save!: form)
      end

      shared_examples "submission email update" do
        it "changes the form submission email" do
          expect(FormRepository).to receive(:save!).with(an_object_having_attributes(submission_email:))
          task.invoke(*valid_args)
        end

        it "updates the email confirmation status" do
          expect(FormRepository).to receive(:save!).with(an_object_having_attributes(email_confirmation_status: :email_set_without_confirmation))
          task.invoke(*valid_args)
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
        context "when use_database_as_truth is false" do
          let(:invalid_args) { ["99", "test@example.com"] }

          before do
            allow(Settings).to receive(:use_database_as_truth).and_return(false)

            ActiveResource::HttpMock.respond_to do |mock|
              mock.get "/api/v1/forms/99", headers, nil, 404
            end
          end

          it "raises an error" do
            expect {
              task.invoke(*invalid_args)
            }.to raise_error(ActiveResource::ResourceNotFound)
          end
        end

        context "when use_database_as_truth is true" do
          let(:invalid_args) { ["99", "test@example.com"] }

          before do
            allow(Settings).to receive(:use_database_as_truth).and_return(true)
          end

          it "raises an error" do
            expect {
              task.invoke(*invalid_args)
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
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
end
