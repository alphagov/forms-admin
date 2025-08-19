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
    end

    def find(condition_id:, page_id:)
      Condition.find_by!(id: condition_id, routing_page_id: page_id)
    end

    def save!(record)
      record.save_and_update_form
      condition = Api::V1::ConditionResource.new(record.attributes, true)
      condition.prefix_options[:form_id] = record.form.id
      condition.prefix_options[:page_id] = record.routing_page_id
      condition.save!
      record
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
  end
end
