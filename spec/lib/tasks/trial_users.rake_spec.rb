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

    it "runs" do
    end
  end

  describe "summarize" do
    before do
      user = create :user
      another_user_with_forms = create :user
      user_without_forms = create :user
      create :editor_user
      create :user, :with_no_org

      form = build :form, id: 1, creator_id: user.id
      another_form = build :form, id: 3, creator_id: user.id
      form_in_group = build :form, id: 2, creator_id: user.id
      another_user_with_forms_forms = build_list(:form, 3) do |f, i|
        f.id = 10 + i
        f.creator_id = another_user_with_forms.id
      end
      group = create :group, creator: user
      GroupForm.create!(form_id: form_in_group.id, group_id: group.id)

      ActiveResource::HttpMock.respond_to do |mock|
        headers = { "X-API-Token" => Settings.forms_api.auth_key, "Accept" => "application/json" }
        mock.get "/api/v1/forms?creator_id=#{user.id}", headers, [form, another_form, form_in_group].to_json, 200
        mock.get "/api/v1/forms?creator_id=#{user_without_forms.id}", headers, [].to_json, 200
        mock.get "/api/v1/forms?creator_id=#{another_user_with_forms.id}", headers, another_user_with_forms_forms.to_json, 200
      end
    end

    it "returns the right output" do
      expect(Summarizer.new.summarize).to eq({
        total_trial_users: 4,
        total_trial_users_with_org_and_name: 3,
        total_trial_users_without_org_or_name: 1,
        total_trial_user_forms_in_groups: 1,
        total_forms_to_add_to_groups: 5,
        total_trial_user_groups_to_create: 2,
        total_trial_user_groups: 1,
        total_trial_users_with_org_name_and_forms: 2,
        total_trial_users_with_groups: 1,
      })
    end
  end
end
