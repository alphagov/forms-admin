require "rails_helper"

RSpec.describe Forms::LiveController, type: :request do
  let(:form) do
    build(:form, :live, id: 2)
  end

  let(:group) { create(:group, organisation: editor_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: editor_user, added_by: editor_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_editor_user
  end

  describe "#show_form" do
    before do
      allow(CloudWatchService).to receive_messages(week_submissions: 501, week_starts: 1305)

      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.get "/api/v1/forms/2/live", headers, form.to_json, 200
      end

      get live_form_path(2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read

      pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
      expect(ActiveResource::HttpMock.requests).to include pages_request
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
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/live", headers, form.to_json, 200
        end

        get live_form_pages_path(2)
      end

      it "renders the live template" do
        expect(response).to render_template(:show_pages)
      end
    end
  end
end
