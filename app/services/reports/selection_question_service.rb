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

  def live_form_pages_with_autocomplete
    pages = all_selection_questions
              .where("answer_settings->>'only_one_option' = 'true'")
              .where("jsonb_array_length(answer_settings->'selection_options') > 30")
              .order("forms.name")

    questions = pages.map { |page| page_data(page) }
    question_list_response(questions)
  end

  def live_form_pages_with_radios
    pages = all_selection_questions
              .where("answer_settings->>'only_one_option' = 'true'")
              .where("jsonb_array_length(answer_settings->'selection_options') <= 30")
              .order("forms.name")

    questions = pages.map { |page| page_data(page) }
    question_list_response(questions)
  end

  def live_form_pages_with_checkboxes
    pages = all_selection_questions
              .where("answer_settings->>'only_one_option' != 'true'")
              .order("forms.name")

    questions = pages.map { |page| page_data(page) }
    question_list_response(questions)
  end

private

  def question_list_response(questions)
    OpenStruct.new(questions:)
  end

  def all_selection_questions
    Page.joins(:form)
        .where(forms: { state: %w[live live_with_draft] }, answer_type: "selection")
        .select("pages.*", "forms.id AS form_id", "forms.name AS form_name")
  end

  def page_data(page)
    OpenStruct.new(
      form_id: page.form_id,
      form_name: page.form_name,
      question_text: page.question_text,
      is_optional: page.is_optional,
      selection_options_count: page.answer_settings["selection_options"].length,
    )
  end
end
