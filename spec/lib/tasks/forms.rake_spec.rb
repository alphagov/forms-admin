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
      ActiveResource::HttpMock.respond_to do |mock|
        forms.each do |form|
          mock.get "/api/v1/forms/#{form.id}", headers, form.to_json, 200
        end
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
        let(:invalid_args) { ["99", group.external_id] }

        before do
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
    end
  end
end
