require "rails_helper"

RSpec.describe FormsController, type: :controller do
  subject(:controller) { described_class.new }

  let(:form) { create :form }

  describe "#current_form" do
    before do
      controller.params = ActionController::Parameters.new(form_id: form.id)
    end

    it "returns the current form" do
      expect(controller.current_form).to eq form
    end

    it "memorizes the find form request so it doesn't have to repeat the calls" do
      allow(Form).to receive(:find).with(form.id).and_return(form)

      controller.current_form
      controller.current_form

      expect(Form).to have_received(:find).exactly(1).times
    end
  end
end
