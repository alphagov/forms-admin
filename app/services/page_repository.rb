class PageRepository
  class << self
    def find(page_id:, form_id:)
      if Settings.use_database_as_truth
        Page.find_by!(id: page_id, form_id:)
      else
        page = Api::V1::PageResource.find(page_id, params: { form_id: })
        save_to_database!(page)
      end
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
      if Settings.use_database_as_truth
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
      else
        page_resource = Api::V1::PageResource.create!(
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
        update_and_save_to_database!(page_resource)
      end
    end

    def save!(record)
      if Settings.use_database_as_truth
        record.save_and_update_form
        page = Api::V1::PageResource.new(record.attributes, true)
        page.prefix_options[:form_id] = record.form.id
        page.save!
        record
      else
        page = Api::V1::PageResource.new(record.attributes, true)
        page.prefix_options[:form_id] = record.form.id
        page.save!
        update_and_save_to_database!(page)
      end
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
      page = Api::V1::PageResource.new(record.attributes, true)
      page.prefix_options[:form_id] = record.form.id

      if Settings.use_database_as_truth
        record.move_page(direction)
        page.move_page(direction)
        record
      else
        page.move_page(direction)
        update_and_save_to_database!(page)
      end
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
      Page.find(record.id)
    end

    def update_and_save_to_database!(record)
      attributes = record.database_attributes

      page_record = begin
        # transaction is required to be able to retry after catching exception
        ActiveRecord::Base.transaction do
          page = Page.find_or_initialize_by(id: record.id)
          page.assign_attributes(**attributes)
          page.save_and_update_form
          page
        end
      # we get an exception if the form does not already exist in the database
      rescue ActiveRecord::RecordInvalid => e
        raise unless e.message.include? "Form must exist"

        find_form_and_save_to_database!(record)

        retry
      end

      save_routing_conditions_to_database!(record)
      page_record
    end
  end
end
