class Reports::SelectionQuestionService
  def initialize(form_documents)
    @form_documents = form_documents
  end

  def statistics
    statistics = {
      autocomplete: {
        form_ids: Set.new,
        question_count: 0,
        optional_question_count: 0,
      },
      radios: {
        form_ids: Set.new,
        question_count: 0,
        optional_question_count: 0,
      },
      checkboxes: {
        form_ids: Set.new,
        question_count: 0,
        optional_question_count: 0,
      },
    }

    @form_documents.each do |form|
      form["content"]["steps"].each do |step|
        next unless step["data"]["answer_type"] == "selection"

        if step["data"]["answer_settings"]["only_one_option"] == "true"
          if step["data"]["answer_settings"]["selection_options"].length > 30
            statistics[:autocomplete][:form_ids].add(form["form_id"])
            statistics[:autocomplete][:question_count] += 1
            statistics[:autocomplete][:optional_question_count] += 1 if step["data"]["is_optional"]
          else
            statistics[:radios][:form_ids].add(form["form_id"])
            statistics[:radios][:question_count] += 1
            statistics[:radios][:optional_question_count] += 1 if step["data"]["is_optional"]
          end
        else
          statistics[:checkboxes][:form_ids].add(form["form_id"])
          statistics[:checkboxes][:question_count] += 1
          statistics[:checkboxes][:optional_question_count] += 1 if step["data"]["is_optional"]
        end
      end
    end

    statistics
  end
end
