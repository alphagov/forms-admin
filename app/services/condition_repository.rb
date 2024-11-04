class ConditionRepository
  class << self
    def create!(form_id:,
                page_id:,
                check_page_id:,
                routing_page_id:,
                answer_value:,
                goto_page_id:,
                skip_to_end:)

      Condition.create!(form_id:,
                        page_id:,
                        check_page_id:,
                        routing_page_id:,
                        answer_value:,
                        goto_page_id:,
                        skip_to_end:)
    end

    def find(condition_id, params:)
      Condition.find(condition_id, params:)
    end

    def save!(record)
      Condition.new(record.attributes, true).save!
    end

    def destroy(record)
      Condition.new(record.attributes, true).destroy
    end
  end
end
