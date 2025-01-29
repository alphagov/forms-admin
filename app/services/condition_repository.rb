class ConditionRepository
  class << self
    def create!(form_id:,
                page_id:,
                check_page_id:,
                routing_page_id:,
                answer_value:,
                goto_page_id:,
                skip_to_end:)
      Api::V1::ConditionResource.create!(form_id:,
                                         page_id:,
                                         check_page_id:,
                                         routing_page_id:,
                                         answer_value:,
                                         goto_page_id:,
                                         skip_to_end:)
    end

    def find(condition_id:, form_id:, page_id:)
      Api::V1::ConditionResource.find(condition_id, params: { form_id:, page_id: })
    end

    def save!(record)
      condition = Api::V1::ConditionResource.new(record.attributes, true)
      condition.prefix_options = record.prefix_options
      condition.save!
    end

    def destroy(record)
      condition = Api::V1::ConditionResource.new(record.attributes, true)
      condition.prefix_options = record.prefix_options
      condition.destroy # rubocop:disable Rails/SaveBang
    end
  end
end
