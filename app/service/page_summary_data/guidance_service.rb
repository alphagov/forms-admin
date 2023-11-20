module PageSummaryData
  class GuidanceService
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
      return nil unless draft_question.page_heading.present? && draft_question.guidance_markdown.present?

      { rows: options }
    end

  private

    def options
      [{
        key: { text: "Page heading" },
        value: { text: draft_question.page_heading },
        actions: [{ href: change_url, visually_hidden_text: "page heading" }],
      },
       {
         key: { text: "Guidance text" },
         value: {
           text: markdown_content,
         },
         actions: [{ href: change_url, visually_hidden_text: "guidance text" }],
       }]
    end

    def markdown_content
      safe_join(['<pre class="app-markdown-editor__markdown-example-block">'.html_safe, draft_question.guidance_markdown, "</pre>".html_safe])
    end

    def change_url
      if draft_question.page_id.present?
        guidance_edit_path(form_id: form.id, page_id: draft_question.page_id)
      else
        guidance_new_path(form_id: form.id)
      end
    end
  end
end
