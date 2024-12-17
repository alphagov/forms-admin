require "rails_helper"

RSpec.describe Forms::ArchivedController, type: :request do
  let(:form) { build(:form, :live, id:) }
  let(:id) { 2 }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user

    allow(FormRepository).to receive_messages(find: form, find_archived: form)
  end

  describe "#show_form" do
    before do
      get archived_form_path(id)
    end

    it "Reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "renders the show archived form template" do
      expect(response).to render_template(:show_form)
    end
  end

  describe "#show_pages" do
    before do
      get archived_form_pages_path(id)
    end

    it "renders the show archived form pages template" do
      expect(response).to render_template(:show_pages)
    end
  end
end
