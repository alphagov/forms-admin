RSpec.shared_examples "transition to live state" do |form_object, form_state|
  let(:form) { form_object.new(state: form_state) }

  before do
    allow(form).to receive(:ready_for_live).and_return(true)
  end

  it "transitions to live state" do
    allow(form).to receive(:touch)

    expect(form).to transition_from(form_state).to(:live).on_event(:make_live)
  end
end
