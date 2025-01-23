require "rails_helper"

RSpec.describe Pages::AddressSettingsController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, answer_type: "address", form_id: 1 }

  let(:draft_question) do
    create :draft_question_for_new_page,
           answer_type: "address",
           user: standard_user,
           form_id: form.id,
           answer_settings: {
             input_type: {
               uk_address: true.to_s,
               international_address: false.to_s,
             },
           }
  end

  let(:address_settings_input) { build :address_settings_input, draft_question: }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    allow(FormRepository).to receive_messages(find: form, pages: pages)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      get address_settings_new_path(form_id: form.id)
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "sets an instance variable for address_settings_path" do
      path = assigns(:address_settings_path)
      expect(path).to eq address_settings_new_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/address_settings")
    end
  end

  describe "#create" do
    context "when form is invalid" do
      before do
        post address_settings_create_path form_id: form.id, params: { pages_address_settings_input: { input_type: nil } }
      end

      it "renders the address settings view if there are errors" do
        expect(response).to have_rendered("pages/address_settings")
      end
    end

    context "when form is valid and ready to store" do
      before do
        post address_settings_create_path form_id: form.id, params: { pages_address_settings_input: { uk_address: address_settings_input.uk_address, international_address: address_settings_input.international_address } }
      end

      let(:address_settings_input) { build :address_settings_input }

      it "saves the input type to draft question" do
        form = assigns(:address_settings_input)
        expect(form.draft_question.answer_settings).to include(input_type: { uk_address: address_settings_input.uk_address, international_address: address_settings_input.international_address })
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to new_question_path(form.id)
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_address_settings, id: 2, form_id: form.id }
    let(:draft_question) do
      create :draft_question,
             answer_type: "address",
             user: standard_user,
             form_id: form.id,
             page_id: page.id,
             answer_settings: {
               input_type: {
                 uk_address: true.to_s,
                 international_address: false.to_s,
               },
             }
    end

    before do
      allow(PageRepository).to receive(:find).and_return(page)

      draft_question
      get address_settings_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "returns the existing page input type" do
      form = assigns(:address_settings_input)
      expect(form.uk_address).to eq draft_question.answer_settings[:input_type][:uk_address]
      expect(form.international_address).to eq draft_question.answer_settings[:input_type][:international_address]
    end

    it "sets an instance variable for address_settings_path" do
      path = assigns(:address_settings_path)
      expect(path).to eq address_settings_edit_path(form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/address_settings")
    end
  end

  describe "#update" do
    let(:page) do
      new_page = build :page, :with_address_settings, id: 2, form_id: form.id
      new_page.answer_settings = { input_type: { uk_address: "false", international_address: "true" } }
      new_page
    end

    before do
      allow(PageRepository).to receive_messages(find: page, save!: page)
    end

    context "when form is valid and ready to update in the DB" do
      let(:input_type) { { uk_address:, international_address: } }
      let(:uk_address) { page.answer_settings.input_type.uk_address }
      let(:international_address) { page.answer_settings.input_type.international_address }

      before do
        post address_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_address_settings_input: { uk_address: "true", international_address: "false" } }
      end

      it "saves the params to draft question" do
        form_instance_variable = assigns(:address_settings_input)
        expect(form_instance_variable.uk_address).to eq "true"
        expect(form_instance_variable.international_address).to eq "false"
        expect(form_instance_variable.draft_question.answer_settings).to include(input_type: { uk_address: "true", international_address: "false" })
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      let(:input_type) { nil }

      before do
        post address_settings_update_path(form_id: page.form_id, page_id: page.id), params: { pages_address_settings_input: { input_type: } }
      end

      it "renders the address settings view if there are errors" do
        expect(response).to have_rendered("pages/address_settings")
      end
    end
  end
end
