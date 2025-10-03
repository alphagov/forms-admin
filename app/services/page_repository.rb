class PageRepository
  class << self
    def create!(form_id:,
                question_text:,
                hint_text:,
                is_optional:,
                is_repeatable:,
                answer_settings:,
                page_heading:,
                guidance_markdown:,
                answer_type:)
      page = Page.new(
        form_id:,
        question_text:,
        hint_text:,
        is_optional:,
        is_repeatable:,
        answer_settings:,
        page_heading:,
        guidance_markdown:,
        answer_type:,
      )
      page.save_and_update_form
      page
    end

    def save!(record)
      record.save_and_update_form
      record
    end

    def destroy(record)
      begin
        Page.find(record.id).destroy_and_update_form!
      rescue ActiveRecord::RecordNotFound
        # ActiveRecord::Persistence#destroy doesn't raise an error
        # if record has already been destroyed, let's emulate that
      end

      record
    end

    def move_page(record, direction)
      record.move_page(direction)
      record
    end
  end
end
