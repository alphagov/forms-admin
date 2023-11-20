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
      return nil unless page.page_heading.present? && page.guidance_markdown.present?

      { rows: options }
    end

  private

    def options
      [{
        key: { text: "Page heading" },
        value: { text: page.page_heading },
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
      safe_join(['<pre class="app-markdown-editor__markdown-example-block">'.html_safe, page.guidance_markdown, "</pre>".html_safe])
    end

    def change_url
      if page.page_id.present?
        guidance_edit_path(form_id: form.id, page_id: page.page_id)
      else
        guidance_new_path(form_id: form.id)
      end
    end
  end
end
