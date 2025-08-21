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
      if Settings.use_database_as_truth
        condition = Condition.new(
          check_page_id:,
          routing_page_id:,
          answer_value:,
          goto_page_id:,
          skip_to_end:,
          exit_page_heading:,
          exit_page_markdown:,
        )
        condition.save_and_update_form
        Api::V1::ConditionResource.create!(condition.attributes.merge(form_id:, page_id:))
        condition
      else
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
        update_and_save_to_database!(condition)
      end
    end

    def find(condition_id:, form_id:, page_id:)
      if Settings.use_database_as_truth
        Condition.find_by!(id: condition_id, routing_page_id: page_id)
      else
        condition = Api::V1::ConditionResource.find(condition_id, params: { form_id:, page_id: })
        save_to_database!(condition)
      end
    end

    def save!(record)
      if Settings.use_database_as_truth
        record.save_and_update_form
        condition = Api::V1::ConditionResource.new(record.attributes, true)
        condition.prefix_options[:form_id] = record.form.id
        condition.prefix_options[:page_id] = record.routing_page_id
        condition.save!
        record
      else
        condition = Api::V1::ConditionResource.new(record.attributes, true)
        condition.prefix_options[:form_id] = record.form.id
        condition.prefix_options[:page_id] = record.routing_page_id
        condition.save!
        update_and_save_to_database!(condition)
      end
    end

    def destroy(record)
      condition = Api::V1::ConditionResource.new(record.attributes, true)
      condition.prefix_options[:form_id] = record.form.id
      condition.prefix_options[:page_id] = record.routing_page_id

      begin
        condition.destroy # rubocop:disable Rails/SaveBang
      rescue ActiveResource::ResourceNotFound
        # ActiveRecord::Persistence#destroy doesn't raise an error
        # if record has already been destroyed, let's emulate that
      end

      begin
        Condition.find(record.id).destroy_and_update_form!
      rescue ActiveRecord::RecordNotFound
        # as above
      end

      record
    end

  private

    def save_to_database!(record)
      Condition.upsert(record.database_attributes)
      Condition.find(record.id)
    end

    def update_and_save_to_database!(record)
      condition = Condition.find_or_initialize_by(id: record.id)
      condition.assign_attributes(record.database_attributes)
      condition.save_and_update_form
      condition
    end
  end
end
