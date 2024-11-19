class PageRepository
  class << self
    def find(page_id:, form_id:)
      Page.find(page_id, params: { form_id: })
    end

    def create!(form_id:,
                question_text:,
                hint_text:,
                is_optional:,
                is_repeatable:,
                answer_settings:,
                page_heading:,
                guidance_markdown:,
                answer_type:)

      Page.create!(form_id:,
                   question_text:,
                   hint_text:,
                   is_optional:,
                   is_repeatable:,
                   answer_settings:,
                   page_heading:,
                   guidance_markdown:,
                   answer_type:)
    end

    def save!(record)
      page = Page.new(record.attributes, true)
      page.prefix_options = record.prefix_options
      page.save!
      page
    end

    def destroy(record)
      page = Page.new(record.attributes, true)
      page.prefix_options = record.prefix_options
      page.destroy # rubocop:disable Rails/SaveBang
    end

    def move_page(record, direction)
      page = Page.new(record.attributes, true)
      page.prefix_options = record.prefix_options
      page.move_page(direction)
    end
  end
end
