require "rake"
require "rails_helper"

RSpec.describe "fix_copied_form_creators.rake" do
  before do
    Rake.application.rake_require "tasks/fix_copied_form_creators"
    Rake::Task.define_task(:environment)
  end

  let(:original_creator) { create :user }
  let(:logged_in_user) { create :user }
  let(:original_form) { create :form, creator_id: original_creator.id }

  describe "forms:copied:fix_creators" do
    subject(:task) do
      Rake::Task["forms:copied:fix_creators"]
        .tap(&:reenable)
    end

    context "when copied form creator matches original form creator" do
      let!(:copied_form) { create :form, creator_id: original_creator.id }

      before do
        stub_const("COPIED_FORMS_DATA", [
          { original_form_id: original_form.id, copied_form_id: copied_form.id, user_id: logged_in_user.id },
        ])
      end

      it "updates the copied form creator to the logged in user" do
        expect {
          task.invoke
        }.to change { copied_form.reload.creator_id }.from(original_creator.id).to(logged_in_user.id)
      end
    end

    context "when logged in user is the creator of the original form" do
      let(:original_form) { create :form, creator_id: logged_in_user.id }
      let!(:copied_form) { create :form, creator_id: logged_in_user.id }

      before do
        stub_const("COPIED_FORMS_DATA", [
          { original_form_id: original_form.id, copied_form_id: copied_form.id, user_id: logged_in_user.id },
        ])
      end

      it "does not update the copied form creator" do
        expect {
          task.invoke
        }.not_to(change { copied_form.reload.creator_id })
      end
    end

    context "when copied form creator differs from original form creator" do
      let(:different_creator) { create :user }
      let!(:copied_form) { create :form, creator_id: different_creator.id }

      before do
        stub_const("COPIED_FORMS_DATA", [
          { original_form_id: original_form.id, copied_form_id: copied_form.id, user_id: logged_in_user.id },
        ])
      end

      it "does not update the copied form creator" do
        expect {
          task.invoke
        }.not_to(change { copied_form.reload.creator_id })
      end
    end

    context "when original form does not exist" do
      let!(:copied_form) { create :form, creator_id: original_creator.id }

      before do
        stub_const("COPIED_FORMS_DATA", [
          { original_form_id: 999_999, copied_form_id: copied_form.id, user_id: logged_in_user.id },
        ])
      end

      it "does not update the copied form creator" do
        expect {
          task.invoke
        }.not_to(change { copied_form.reload.creator_id })
      end
    end

    context "when copied form does not exist" do
      before do
        stub_const("COPIED_FORMS_DATA", [
          { original_form_id: original_form.id, copied_form_id: 999_999, user_id: logged_in_user.id },
        ])
      end

      it "does not raise an error" do
        expect { task.invoke }.not_to raise_error
      end
    end

    context "when logged in user does not exist" do
      let!(:copied_form) { create :form, creator_id: original_creator.id }

      before do
        stub_const("COPIED_FORMS_DATA", [
          { original_form_id: original_form.id, copied_form_id: copied_form.id, user_id: 999_999 },
        ])
      end

      it "does not update the copied form creator" do
        expect {
          task.invoke
        }.not_to(change { copied_form.reload.creator_id })
      end
    end

    context "with multiple rows" do
      let!(:first_copied_form) { create :form, creator_id: original_creator.id }
      let!(:second_copied_form) { create :form, creator_id: original_creator.id }
      let(:different_creator) { create :user }
      let!(:copied_form3) { create :form, creator_id: different_creator.id }

      before do
        stub_const("COPIED_FORMS_DATA", [
          { original_form_id: original_form.id, copied_form_id: first_copied_form.id, user_id: logged_in_user.id },
          { original_form_id: original_form.id, copied_form_id: second_copied_form.id, user_id: logged_in_user.id },
          { original_form_id: original_form.id, copied_form_id: copied_form3.id, user_id: logged_in_user.id },
        ])
      end

      it "updates forms where creators match" do
        task.invoke

        expect(first_copied_form.reload.creator_id).to eq(logged_in_user.id)
        expect(second_copied_form.reload.creator_id).to eq(logged_in_user.id)
      end

      it "skips forms where creators differ" do
        expect {
          task.invoke
        }.not_to(change { copied_form3.reload.creator_id })
      end
    end
  end

  describe "forms:copied:fix_creators_dry_run" do
    subject(:task) do
      Rake::Task["forms:copied:fix_creators_dry_run"]
        .tap(&:reenable)
    end

    context "when copied form creator matches original form creator" do
      let!(:copied_form) { create :form, creator_id: original_creator.id }

      before do
        stub_const("COPIED_FORMS_DATA", [
          { original_form_id: original_form.id, copied_form_id: copied_form.id, user_id: logged_in_user.id },
        ])
      end

      it "does not persist changes to the database" do
        expect {
          task.invoke
        }.not_to(change { copied_form.reload.creator_id })
      end
    end
  end
end
