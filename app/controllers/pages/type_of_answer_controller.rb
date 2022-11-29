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
      redirect_to new_page_path(@form)
    else
      @type_of_answer_path = type_of_answer_create_path(@form)
      render "pages/type-of-answer"
    end
  end

  def edit
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @type_of_answer_form = Forms::TypeOfAnswerForm.new(answer_type: @page.answer_type)
    @type_of_answer_path = type_of_answer_update_path(@form)
    render "pages/type-of-answer"
  end

  def update
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @type_of_answer_form = Forms::TypeOfAnswerForm.new(answer_type_form_params)
    @page.answer_type = @type_of_answer_form.answer_type if @type_of_answer_form.valid?

    if @type_of_answer_form.valid? && @page.save!
      redirect_to edit_page_path(@form)
    else
      @type_of_answer_path = type_of_answer_update_path(@form)
      render "pages/type-of-answer"
    end
  end

private

  def answer_type_form_params
    form = Form.find(params[:form_id])
    params.require(:forms_type_of_answer_form).permit(:answer_type).merge(form:)
  end
end
