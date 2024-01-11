module PageSummaryData
  class QuestionService
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::OutputSafetyHelper

    class << self
      def call(**args)
        new(**args)
      end
    end

    attr_reader :form, :draft_question

    def initialize(form:, draft_question:)
      @form = form
      @draft_question = draft_question
    end

    def build_data
      return nil if draft_question.question_text.blank?

      { rows: options }
    end

  private

    def options
      [{
        key: { text: "Question" },
        value: { text: draft_question.question_text },
        actions: [{ href: change_url, visually_hidden_text: "question" }],
      },
       {
         key: { text: "Hint text (optional)" },
         value: { text: draft_question.hint_text },
         actions: [{ href: change_url, visually_hidden_text: "hint text" }],
       },
       {
         key: { text: "Add guidance" },
         value: { text: has_guidance },
         actions: [{ href: change_url, visually_hidden_text: "guidance" }],
       },
       {
         key: { text: "Make this question optional" },
         value: { text: draft_question.is_optional? ? "Yes" : "No" },
         actions: [{ href: change_url, visually_hidden_text: "guidance" }],
       }]
    end

    def change_url
      if draft_question.page_id.present?
        edit_question_path(form_id: form.id, page_id: draft_question.page_id)
      else
        new_question_path(form_id: form.id)
      end
    end

    def has_guidance
      return "No" if draft_question.page_heading.blank? && draft_question.guidance_markdown.blank?

      "Yes"
    end
  end
end
