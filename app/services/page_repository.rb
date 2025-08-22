class PageRepository
  class << self
    def find(page_id:, form_id:)
      Page.find_by!(id: page_id, form_id:)
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
      Api::V1::PageResource.create!(page.attributes)
      page
    end

    def save!(record)
      record.save_and_update_form
      page = Api::V1::PageResource.new(record.attributes, true)
      page.prefix_options[:form_id] = record.form.id
      page.save!
      record
    end

    def destroy(record)
      page = Api::V1::PageResource.new(record.attributes, true)
      page.prefix_options[:form_id] = record.form.id

      begin
        page.destroy # rubocop:disable Rails/SaveBang
      rescue ActiveResource::ResourceNotFound
        # ActiveRecord::Persistence#destroy doesn't raise an error
        # if record has already been destroyed, let's emulate that
      end

      begin
        Page.find(record.id).destroy_and_update_form!
      rescue ActiveRecord::RecordNotFound
        # as above
      end

      record
    end

    def move_page(record, direction)
      record.move_page(direction)

      page = Api::V1::PageResource.new(record.attributes, true)
      page.prefix_options[:form_id] = record.form.id
      page.move_page(direction)
      record
    end
  end
end
