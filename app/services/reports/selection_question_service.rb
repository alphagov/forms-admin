class Reports::SelectionQuestionService
  UsageStatistics = Struct.new(:unique_form_ids_set, :question_count, :optional_question_count) do
    def form_count
      unique_form_ids_set.length
    end
  end

  def initialize(form_documents)
    @form_documents = form_documents
  end

  def statistics
    statistics = OpenStruct.new(
      autocomplete: UsageStatistics.new(Set.new, 0, 0),
      radios: UsageStatistics.new(Set.new, 0, 0),
      checkboxes: UsageStatistics.new(Set.new, 0, 0),
    )

    @form_documents.each do |form|
      form["content"]["steps"].each do |step|
        next unless step["data"]["answer_type"] == "selection"

        if step["data"]["answer_settings"]["only_one_option"] == "true"
          if step["data"]["answer_settings"]["selection_options"].length > 30
            statistics[:autocomplete].unique_form_ids_set.add(form["form_id"])
            statistics[:autocomplete].question_count += 1
            statistics[:autocomplete].optional_question_count += 1 if step["data"]["is_optional"]
          else
            statistics[:radios].unique_form_ids_set.add(form["form_id"])
            statistics[:radios].question_count += 1
            statistics[:radios].optional_question_count += 1 if step["data"]["is_optional"]
          end
        else
          statistics[:checkboxes].unique_form_ids_set.add(form["form_id"])
          statistics[:checkboxes].question_count += 1
          statistics[:checkboxes].optional_question_count += 1 if step["data"]["is_optional"]
        end
      end
    end

    statistics
  end
end
