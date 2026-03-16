RSpec.shared_examples "an add a new question page that expects a certain answer type" do |expected_answer_type|
  context "when the answer type for the draft question is not selection" do
    let(:answer_type) { expected_answer_type == "text" ? "name" : "text" }
    let(:expected_redirect_path) { answer_type == "text" ? text_settings_new_path(form.id) : name_settings_new_path(form.id) }
    let(:draft_question) { create :draft_question, answer_type:, user:, form_id: form.id }

    it "redirects to the start page for creating a question of the answer type" do
      expect(response).to redirect_to expected_redirect_path
    end
  end

  context "when there is no draft question" do
    let(:draft_question) { nil }

    it "redirects to the new question page" do
      expect(response).to redirect_to new_question_path(form.id)
    end
  end
end

RSpec.shared_examples "an edit question page that expects a certain answer type" do |expected_answer_type|
  let(:answer_type) { expected_answer_type == "text" ? "name" : "text" }
  let(:draft_question) { create :draft_question, answer_type:, user:, form_id: form.id, page_id: page.id }

  it "redirects to the edit question page" do
    expect(response).to redirect_to edit_question_path(form.id, page.id)
  end
end
