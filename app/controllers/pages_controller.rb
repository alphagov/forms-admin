class PagesController < ApplicationController
  include CheckFormOrganisation
  before_action :fetch_form, :answer_types
  skip_before_action :clear_questions_session_data

  def new
    answer_type = session.dig(:page, "answer_type")
    answer_settings = session.dig(:page, "answer_settings")
    is_optional = session.dig(:page, "is_optional") == "true"
    @page = Page.new(form_id: @form.id, answer_type:, answer_settings:, is_optional:)
  end

  def create
    answer_settings = session.dig(:page, "answer_settings")
    @page = Page.new(page_params.merge(answer_settings:))

    if @page.save
      clear_questions_session_data
      handle_submit_action
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    reset_session_if_answer_settings_not_present
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @page.load_from_session(session, %w[answer_settings answer_type is_optional])
  end

  def update
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @page.load_from_session(session, %w[answer_type answer_settings]).load(page_params)

    if @page.save
      clear_questions_session_data
      handle_submit_action
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def page_params
    params.require(:page).permit(:question_text, :question_short_name, :hint_text, :answer_type, :is_optional).merge(form_id: @form.id)
  end

  def fetch_form
    @form = Form.find(params[:form_id])
  end

  def reset_session_if_answer_settings_not_present
    answer_type = session.dig(:page, "answer_type")
    answer_settings = session.dig(:page, "answer_settings")

    if (Page::ANSWER_TYPES_WITH_SETTINGS.include? answer_type) && (answer_settings.blank? || answer_settings == {})
      clear_questions_session_data
      redirect_to edit_page_path(params[:form_id], params[:page_id])
    end
  end

  def handle_submit_action
    # if user chose to save and reload current page
    return redirect_to edit_page_path(@form, @page) if params[:save_preview]

    return redirect_to delete_page_path(@form, @page) if params[:delete]

    # Default: either edit the next page or create a new one
    if @page.has_next_page?
      redirect_to edit_page_path(@form, @page.next_page)
    else
      redirect_to type_of_answer_new_path(@form)
    end
  end

  def answer_types
    @answer_types = if FeatureService.enabled?(:autocomplete_answer_types)
                      Page::ANSWER_TYPES.reject { |e| %w[single_line long_text].include?(e) }
                    else
                      Page::ANSWER_TYPES.reject { |e| %w[organisation_name text name].include?(e) }
                    end
  end
end
