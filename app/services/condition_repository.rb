class ConditionRepository
  class << self
    def save!(record)
      record.save_and_update_form
      record
    end

    def destroy(record)
      begin
        Condition.find(record.id).destroy_and_update_form!
      rescue ActiveRecord::RecordNotFound
        # ActiveRecord::Persistence#destroy doesn't raise an error
        # if record has already been destroyed, let's emulate that
      end

      record
    end
  end
end
