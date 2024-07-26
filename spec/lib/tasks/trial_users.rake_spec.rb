require "rake"

require "rails_helper"

RSpec.describe "trial_users.rake" do
  before do
    Rake.application.rake_require "tasks/trial_users"
    Rake::Task.define_task(:environment)
  end

  describe "trial_users:summary" do
    subject(:task) do
      Rake::Task["trial_users:summary"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    let(:summarizer_double) { instance_double(Summarizer) }

    before do
      allow($stdout).to receive(:puts)
    end

    it "runs" do
      expect { task.invoke }.not_to raise_error
    end

    it "calls summarize" do
      allow(Summarizer).to receive(:new).and_return(summarizer_double)
      allow(summarizer_double).to receive(:summarize)

      task.invoke
      expect(summarizer_double).to have_received(:summarize).once
    end
  end

  describe "summarize" do
    before do
      user = create :user, :trial, name: "A User"
      another_user_with_forms = create :user, :trial
      user_without_forms = create :user, :trial
      user_with_form_but_no_org_or_name = create :user, :trial, :with_no_name, :with_no_org
      user_with_no_org_and_no_forms = create :user, :trial, :with_no_org
      create :user, :editor

      form = build :form, id: 1, creator_id: user.id
      another_form = build :form, id: 2, creator_id: user.id
      form_in_group = build :form, id: 3, creator_id: user.id
      form_in_default_group = build :form, id: 4, creator_id: user.id
      old_form = build :form, id: 5, creator_id: user_with_form_but_no_org_or_name
      another_user_with_forms_forms = build_list(:form, 3) do |f, i|
        f.id = 10 + i
        f.creator_id = another_user_with_forms.id
      end
      group = create :group, creator: user
      GroupForm.create!(form_id: form_in_group.id, group_id: group.id)
      default_group = create :group, creator: user, name: "A User’s trial group", status: :trial
      GroupForm.create!(form_id: form_in_default_group.id, group: default_group)

      ActiveResource::HttpMock.respond_to do |mock|
        headers = { "X-API-Token" => Settings.forms_api.auth_key, "Accept" => "application/json" }
        mock.get "/api/v1/forms?creator_id=#{user.id}", headers, [form, another_form, form_in_group, form_in_default_group].to_json, 200
        mock.get "/api/v1/forms?creator_id=#{user_without_forms.id}", headers, [].to_json, 200
        mock.get "/api/v1/forms?creator_id=#{another_user_with_forms.id}", headers, another_user_with_forms_forms.to_json, 200
        mock.get "/api/v1/forms?creator_id=#{user_with_form_but_no_org_or_name.id}", headers, [old_form].to_json, 200
        mock.get "/api/v1/forms?creator_id=#{user_with_no_org_and_no_forms.id}", headers, [].to_json, 200
      end
    end

    it "returns the right output" do
      expect(Summarizer.new.summarize).to eq({
        total_trial_users: 5,
        total_trial_users_with_forms: 3,
        total_trial_users_with_org_and_name: 3,
        total_trial_users_without_org_or_name: 2,
        total_trial_user_forms_in_groups: 2,
        total_forms_to_add_to_groups: 5,
        total_trial_user_groups_to_create: 2,
        total_trial_user_groups: 2,
        total_trial_users_with_org_name_and_forms: 2,
        total_trial_users_with_groups: 1,
        trial_user_forms_not_in_default_group: [3],
        total_trial_user_forms_not_in_group: 6,
      })
    end
  end
end
