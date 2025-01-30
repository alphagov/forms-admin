require "rails_helper"

RSpec.describe PagesController, type: :controller do
  subject(:controller) { described_class.new }

  let(:form) { build(:form) }
  let(:group) { build(:group) }

  before do
    allow(FormRepository).to receive_messages(find: form)
    allow(form).to receive_messages(group: group)
    params = { form_id: 1 }
    controller.params = ActionController::Parameters.new(params)
  end

  describe "#branching_enabled" do
    context "when Settings.features.branch_routing is enabled" do
      before do
        allow(Settings.features).to receive(:branch_routing).and_return(true)
      end

      it "returns true regardless of group settings" do
        # allow(form.group).to receive(:branching_enabled?).and_return(false)
        group.branching_enabled = false
        expect(controller.branching_enabled).to be true
      end

      it "assigns the branching_enabled variable" do
        controller.branching_enabled
        expect(controller.view_assigns["branching_enabled"]).to be true
      end
    end

    context "when Settings.features.branch_routing is disabled" do
      before do
        allow(Settings.features).to receive(:branch_routing).and_return(false)
      end

      context "when group has branching enabled" do
        before do
          allow(form.group).to receive(:branching_enabled?).and_return(true)
        end

        it "returns true" do
          expect(controller.branching_enabled).to be true
        end
      end

      context "when group has branching disabled" do
        before do
          allow(form.group).to receive(:branching_enabled?).and_return(false)
        end

        it "returns false" do
          expect(controller.branching_enabled).to be false
        end
      end
    end
  end
end
