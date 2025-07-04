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

    def find_form_and_save_to_database!(page_record)
      form_id = page_record.prefix_options[:form_id]
      FormRepository.find(form_id:)
    end

    def save_routing_conditions_to_database!(page_record)
      return if page_record.attributes["routing_conditions"].blank?

      routing_conditions = page_record.routing_conditions.map(&:database_attributes)

      Condition.upsert_all(routing_conditions)

      # delete any routing conditions that may have previously been associated with this page
      page = Page.find(page_record.id)
      page.update!(routing_condition_ids: routing_conditions.pluck("id"))
    end

    def save_to_database!(record)
      attributes = record.database_attributes

      begin
        # transaction is required to be able to retry after catching exception
        ActiveRecord::Base.transaction do
          Page.upsert(attributes)
        end
      # we get an exception if the form does not already exist in the database
      rescue ActiveRecord::InvalidForeignKey => e
        raise unless e.message.include? 'table "forms"'

        find_form_and_save_to_database!(record)

        retry
      end

      save_routing_conditions_to_database!(record)
    end
  end
end
