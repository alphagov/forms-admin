require "rails_helper"

RSpec.describe Forms::LiveController, type: :request do
  let(:form) do
    build(:form, :live, id: 2)
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#show_form" do
    before do
      allow(CloudWatchService).to receive_messages(week_submissions: 501, week_starts: 1305)

      allow(FormRepository).to receive_messages(find: form, find_live: form)

      get live_form_path(2)
    end

    it "Reads the form" do
      expect(FormRepository).to have_received(:find)
      expect(FormRepository).to have_received(:find_live)
    end

    it "renders the live template" do
      expect(response).to render_template(:show_form)
    end

    context "when the form went live today" do
      it "does not read the Cloudwatch API" do
        expect(CloudWatchService).not_to have_received(:week_submissions)
        expect(CloudWatchService).not_to have_received(:week_starts)
      end
    end

    context "when the form went live before today" do
      let(:form) do
        build(:form, :live, id: 2, live_at: Time.zone.now - 1.day)
      end

      it "reads the Cloudwatch API" do
        expect(CloudWatchService).to have_received(:week_submissions).once
        expect(CloudWatchService).to have_received(:week_starts).once
      end
    end
  end

  describe "#show_pages" do
    context "with a live form" do
      before do
        allow(FormRepository).to receive_messages(find: form, find_live: form)

        get live_form_pages_path(2)
      end

      it "renders the live template" do
        expect(response).to render_template(:show_pages)
      end
    end
  end
end
