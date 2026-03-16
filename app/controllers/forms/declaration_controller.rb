module Forms
  class DeclarationController < FormsController
    def new
      authorize current_form, :can_view_form?
      @declaration_input = DeclarationInput.new(form: current_form).assign_form_values
      @preview_html = preview_html(@declaration_input)
    end

    def create
      authorize current_form, :can_view_form?
      @declaration_input = DeclarationInput.new(**declaration_input_params)
      @preview_html = preview_html(@declaration_input)

      if @declaration_input.submit
        success_message = if @declaration_input.mark_complete == "true"
                            t("banner.success.form.declaration_saved_and_completed")
                          else
                            t("banner.success.form.declaration_saved")
                          end

        redirect_to form_path(@declaration_input.form), success: success_message
      else
        render :new
      end
    end

    def render_preview
      authorize current_form, :can_view_form?
      @declaration_input = DeclarationInput.new(declaration_markdown: params[:markdown])
      @declaration_input.validate

      render json: { preview_html: preview_html(@declaration_input), errors: @declaration_input.errors[:declaration_markdown] }.to_json
    end

  private

    def declaration_input_params
      params.require(:forms_declaration_input).permit(:declaration_markdown, :mark_complete).merge(form: current_form)
    end

    def preview_html(declaration_input)
      return t("markdown_editor.no_markdown_content_html") if declaration_input.declaration_markdown.blank?

      GovukFormsMarkdown.render(declaration_input.declaration_markdown, allow_headings: true)
    end
  end
end
