module PageSummaryData
  class GuidanceService
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::OutputSafetyHelper

    class << self
      def call(**args)
        new(**args)
      end
    end

    attr_reader :form, :page

    def initialize(form:, page:)
      @form = form
      @page = page
    end

    def build_data
      return nil unless page.page_heading.present? && page.additional_guidance_markdown.present?

      { rows: options }
    end

  private

    def options
      [{
        key: { text: "Page heading" },
        value: { text: page.page_heading },
        actions: [{ href: additional_guidance_new_path(form_id: form.id), visually_hidden_text: "page heading" }],
      },
       {
         key: { text: "Guidance text" },
         value: {
           text: markdown_content,
         },
         actions: [{ href: additional_guidance_new_path(form_id: form.id), visually_hidden_text: "guidance text" }],
       }]
    end

    def markdown_content
      safe_join(['<pre class="app-markdown-example-block">'.html_safe, page.additional_guidance_markdown, "</pre>".html_safe])
    end
  end
end
