require "rails_helper"

class TestInput < BaseInput
  attr_accessor :name, :email

  validates :name, presence: true
  validates :email, format: { with: /.*@.*/, message: "must be a valid email address" }
end

class TestInputWithForm < BaseInput
  attr_accessor :name, :email, :form

  validates :name, presence: true
  validates :email, format: { with: /.*@.*/, message: "must be a valid email address" }
end

class TestInputWithDraftQuestion < BaseInput
  attr_accessor :name, :email, :draft_question

  validates :name, presence: true
  validates :email, format: { with: /.*@.*/, message: "must be a valid email address" }
end

class TestInputWithPage < BaseInput
  attr_accessor :name, :email, :page

  validates :name, presence: true
  validates :email, format: { with: /.*@.*/, message: "must be a valid email address" }
end

class TestInputWithNestedError < BaseInput
  validate :has_no_nested_errors

  def has_no_nested_errors
    nested_input = TestInput.new
    nested_input.validate

    errors.merge!(nested_input.errors)
  end
end

RSpec.describe BaseInput do
  describe "validation error logging" do
    let(:analytics_service) { class_double(AnalyticsService).as_stubbed_const }

    before do
      allow(CurrentLoggingAttributes).to receive(:validation_errors=)
      allow(analytics_service).to receive(:track_validation_errors)
    end

    context "when there are no validation errors" do
      let(:input) { TestInput.new(name: "John Doe", email: "john@example.com") }

      it "is valid" do
        expect(input).to be_valid
      end

      it "does not log validation errors" do
        input.valid?
        expect(CurrentLoggingAttributes).not_to have_received(:validation_errors=)
      end

      it "does not track validation errors" do
        input.valid?
        expect(analytics_service).not_to have_received(:track_validation_errors)
      end
    end

    context "when there are validation errors" do
      let(:input) { TestInput.new }

      it "is invalid" do
        expect(input).to be_invalid
      end

      it "sets validation errors on CurrentLoggingAttributes" do
        input.valid?

        expect(CurrentLoggingAttributes).to have_received(:validation_errors=)
          .with(array_including("name: blank", "email: invalid"))
      end

      it "tracks each validation error through AnalyticsService" do
        input.valid?

        expect(analytics_service).to have_received(:track_validation_errors)
          .with(input_object_name: "TestInput", form_name: nil, field: :name, error_type: :blank)

        expect(analytics_service).to have_received(:track_validation_errors)
          .with(input_object_name: "TestInput", form_name: nil, field: :email, error_type: :invalid)
      end

      context "when the form is defined in the input" do
        let(:input) { TestInputWithForm.new }

        context "when the form is nil" do
          it "does not include a form name in the validation errors" do
            input.valid?

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithForm", form_name: nil, field: :name, error_type: :blank)

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithForm", form_name: nil, field: :email, error_type: :invalid)
          end
        end

        context "when the form is present" do
          let(:form_name) { "Apply for a juggling licence" }
          let(:form) { OpenStruct.new(name: form_name) }
          let(:input) { TestInputWithForm.new(form:) }

          it "includes the form name in the validation errors" do
            input.valid?

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithForm", form_name:, field: :name, error_type: :blank)

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithForm", form_name:, field: :email, error_type: :invalid)
          end
        end
      end

      context "when the draft_question is defined in the input" do
        let(:input) { TestInputWithDraftQuestion.new }

        context "when the draft_question is nil" do
          it "does not include a form name in the validation errors" do
            input.valid?

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithDraftQuestion", form_name: nil, field: :name, error_type: :blank)

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithDraftQuestion", form_name: nil, field: :email, error_type: :invalid)
          end
        end

        context "when the draft_question is present" do
          let(:form_name) { "Apply for a juggling licence" }
          let(:form) { create :form, name: form_name }
          let(:draft_question) { build :draft_question, form_id: form.id }
          let(:input) { TestInputWithDraftQuestion.new(draft_question:) }

          it "includes the form name in the validation errors" do
            input.valid?

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithDraftQuestion", form_name:, field: :name, error_type: :blank)

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithDraftQuestion", form_name:, field: :email, error_type: :invalid)
          end
        end
      end

      context "when the page is defined in the input" do
        let(:input) { TestInputWithPage.new }

        context "when the page is nil" do
          it "does not include a form name in the validation errors" do
            input.valid?

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithPage", form_name: nil, field: :name, error_type: :blank)

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithPage", form_name: nil, field: :email, error_type: :invalid)
          end
        end

        context "when the page is present" do
          let(:form_name) { "Apply for a juggling licence" }
          let(:form) { create :form, name: form_name }
          let(:page) { build :page, form_id: form.id }
          let(:input) { TestInputWithPage.new(page:) }

          it "includes the form name in the validation errors" do
            input.valid?

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithPage", form_name:, field: :name, error_type: :blank)

            expect(analytics_service).to have_received(:track_validation_errors)
              .with(input_object_name: "TestInputWithPage", form_name:, field: :email, error_type: :invalid)
          end
        end
      end

      context "when there is a nested error on the input" do
        let(:input) { TestInputWithNestedError.new }

        it "is invalid" do
          expect(input).to be_invalid
        end

        it "only sets validation errors on CurrentLoggingAttributes once" do
          input.valid?

          expect(CurrentLoggingAttributes).to have_received(:validation_errors=)
            .with(array_including("name: blank", "email: invalid")).once
        end

        it "tracks the nested model's validation errors through AnalyticsService" do
          input.valid?

          expect(analytics_service).to have_received(:track_validation_errors)
            .with(input_object_name: "TestInput", form_name: nil, field: :name, error_type: :blank).once

          expect(analytics_service).to have_received(:track_validation_errors)
            .with(input_object_name: "TestInput", form_name: nil, field: :email, error_type: :invalid).once
        end

        it "does not track the parent model's validation errors through AnalyticsService" do
          input.valid?

          expect(analytics_service).not_to have_received(:track_validation_errors)
            .with(hash_including(input_object_name: "TestInputWithNestedError"))

          expect(analytics_service).not_to have_received(:track_validation_errors)
            .with(hash_including(input_object_name: "TestInputWithNestedError"))
        end
      end
    end
  end
end
