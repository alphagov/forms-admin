class Pages::TypeOfAnswerController < PagesController
  def new
    answer_type = session[:page]["answer_type"] if session[:page].present?
    @type_of_answer_form = Forms::TypeOfAnswerForm.new(answer_type:)
    @type_of_answer_path = type_of_answer_create_path(@form)
    render "pages/type-of-answer"
  end

  def create
    @type_of_answer_form = Forms::TypeOfAnswerForm.new(answer_type_form_params)

    if @type_of_answer_form.submit(session)
      redirect_to next_page_path(@form, @type_of_answer_form.answer_type, :create)
    else
      @type_of_answer_path = type_of_answer_create_path(@form)
      render "pages/type-of-answer"
    end
  end

  def edit
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @type_of_answer_form = Forms::TypeOfAnswerForm.new(answer_type: @page.answer_type, page: @page)
    @type_of_answer_path = type_of_answer_update_path(@form)
    render "pages/type-of-answer"
  end

  def update
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @type_of_answer_form = Forms::TypeOfAnswerForm.new(answer_type_form_params)
    return redirect_to edit_page_path(@form) unless answer_type_changed?

    @page.answer_type = @type_of_answer_form.answer_type if @type_of_answer_form.valid?
    @page.answer_settings = nil if @type_of_answer_form.valid?

    if @type_of_answer_form.valid? && @page.save!
      redirect_to next_page_path(@form, @type_of_answer_form.answer_type, :update)
    else
      @type_of_answer_path = type_of_answer_update_path(@form)
      render "pages/type-of-answer"
    end
  end

private

  def next_page_path(form, answer_type, action)
    case answer_type
    when "selection"
      action == :create ? selections_settings_new_path(form) : selections_settings_edit_path(form)
    when "text"
      action == :create ? text_settings_new_path(form) : text_settings_edit_path(form)
    when "date"
      action == :create ? date_settings_new_path(form) : date_settings_edit_path(form)
    when "address"
      action == :create ? address_settings_new_path(form) : address_settings_edit_path(form)
    else
      action == :create ? new_page_path(@form) : edit_page_path(@form)
    end
  end

  def answer_type_form_params
    form = Form.find(params[:form_id])
    params.require(:forms_type_of_answer_form).permit(:answer_type).merge(form:)
  end

  def answer_type_changed?
    @type_of_answer_form.answer_type != @page.answer_type
  end
end
