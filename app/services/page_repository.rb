class PageRepository
  class << self
    def find(page_id:, form_id:)
      page = Api::V1::PageResource.find(page_id, params: { form_id: })
      save_to_database!(page)
      page
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
      page = Api::V1::PageResource.create!(
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
      save_to_database!(page)
      page
    end

    def save!(record)
      page = Api::V1::PageResource.new(record.attributes, true)
      page.prefix_options = record.prefix_options
      page.save!
      save_to_database!(page)
      page
    end

    def destroy(record)
      page = Api::V1::PageResource.new(record.attributes, true)
      page.prefix_options = record.prefix_options

      begin
        page.destroy # rubocop:disable Rails/SaveBang
        Page.destroy(record.id)
      rescue ActiveResource::ResourceNotFound, ActiveRecord::RecordNotFound
        # ActiveRecord::Persistence#destroy doesn't raise an error
        # if record has already been destroyed, let's emulate that
      end

      record
    end

    def move_page(record, direction)
      page = Api::V1::PageResource.new(record.attributes, true)
      page.prefix_options = record.prefix_options

      response = page.move_page(direction)
      page.from_json(response.body)

      save_to_database!(page)

      page
    end

  private

    def save_to_database!(record)
      attributes = record.database_attributes
      Page.upsert(attributes)
    end
  end
end
