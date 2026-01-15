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
      include_none_of_the_above: {
        form_ids: Set.new,
        question_count: 0,
        with_follow_up_question: {
          form_ids: Set.new,
          question_count: 0,
          mandatory_follow_up_question_count: 0,
          optional_follow_up_question_count: 0,
        },
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

        include_none_of_the_above = step["data"]["is_optional"]
        next unless include_none_of_the_above

        statistics[:include_none_of_the_above][:form_ids].add(form["form_id"])
        statistics[:include_none_of_the_above][:question_count] += 1

        none_of_the_above_question = step["data"]["answer_settings"]["none_of_the_above_question"]
        next unless none_of_the_above_question

        statistics[:include_none_of_the_above][:with_follow_up_question][:form_ids].add(form["form_id"])
        statistics[:include_none_of_the_above][:with_follow_up_question][:question_count] += 1

        if none_of_the_above_question["is_optional"] == "true"
          statistics[:include_none_of_the_above][:with_follow_up_question][:optional_follow_up_question_count] += 1
        else
          statistics[:include_none_of_the_above][:with_follow_up_question][:mandatory_follow_up_question_count] += 1
        end
      end
    end

    statistics
  end
end
