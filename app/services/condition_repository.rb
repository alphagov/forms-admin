class ConditionRepository
  class << self
    def create!(form_id:,
                page_id:,
                check_page_id:,
                routing_page_id:,
                answer_value:,
                goto_page_id:,
                skip_to_end:,
                exit_page_heading: nil,
                exit_page_markdown: nil)
      condition = Api::V1::ConditionResource.create!(
        form_id:,
        page_id:,
        check_page_id:,
        routing_page_id:,
        answer_value:,
        goto_page_id:,
        skip_to_end:,
        exit_page_heading:,
        exit_page_markdown:,
      )
      save_to_database!(condition)
      condition
    end

    def find(condition_id:, form_id:, page_id:)
      condition = Api::V1::ConditionResource.find(condition_id, params: { form_id:, page_id: })
      save_to_database!(condition)
      condition
    end

    def save!(record)
      condition = Api::V1::ConditionResource.new(record.attributes, true)
      condition.prefix_options = record.prefix_options
      condition.save!
      save_to_database!(condition)
      condition
    end

    def destroy(record)
      condition = Api::V1::ConditionResource.new(record.attributes, true)
      condition.prefix_options = record.prefix_options

      begin
        condition.destroy # rubocop:disable Rails/SaveBang
        Condition.destroy(record.id)
      rescue ActiveResource::ResourceNotFound, ActiveRecord::RecordNotFound
        # ActiveRecord::Persistence#destroy doesn't raise an error
        # if record has already been destroyed, let's emulate that
      end

      record
    end

  private

    def save_to_database!(record)
      Condition.upsert(record.database_attributes)
    end
  end
end
