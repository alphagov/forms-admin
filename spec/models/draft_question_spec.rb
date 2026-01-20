require "rails_helper"

RSpec.describe DraftQuestion, type: :model do
  let(:draft_question) { build(:draft_question, user:, question_text:) }
  let(:user) { build :user }
  let(:question_text) { "What is your full name?" }

  it "has a valid factory" do
    expect(build(:draft_question, user:)).to be_valid
  end

  describe "validations" do
    it "requires a form_id" do
      draft_question.form_id = nil
      expect(draft_question).not_to be_valid
    end
  end

  describe "answer_settings" do
    let(:draft_question) { create :draft_question, answer_settings: }
    let(:answer_settings) do
      {
        "hello" => "I have a string as a key",
        "nested_attributes" => {
          "name" => "Joe Bloggs",
        },
      }
    end

    it "returns a hash with all keys as symbols" do
      expect(draft_question.answer_settings).to eq(hello: "I have a string as a key",
                                                   nested_attributes: {
                                                     name: "Joe Bloggs",
                                                   })
    end

    context "when answer_settings is empty JSON" do
      let(:answer_settings) { {} }

      it "returns empty hash" do
        expect(draft_question.answer_settings).to be_empty
      end
    end

    context "when answer_settings is nil" do
      let(:answer_settings) { nil }

      it "returns empty hash" do
        expect(draft_question.answer_settings).to be_empty
      end
    end
  end

  describe "form_name" do
    let(:form) { create :form }
    let(:draft_question) { create :draft_question, form_id: form.id }

    it "returns the name of the associated form" do
      expect(draft_question.form_name).to eq(form.name)
    end

    context "when the associated form does not exist" do
      let(:draft_question) { create :draft_question, form_id: 0 }

      it "throws a NotFoundError" do
        expect { draft_question.form_name }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#form" do
    context "when the associated form exists" do
      let(:form) { create :form }
      let(:draft_question) { create :draft_question, form_id: form.id }

      it "returns the associated form" do
        expect(draft_question.form).to eq(form)
      end
    end

    context "when the associated form does not exist" do
      let(:draft_question) { create :draft_question, form_id: 0 }

      it "throws a NotFoundError" do
        expect { draft_question.form }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
