
require "govuk_forms_markdown"

class Pages::AdditionalGuidanceController < PagesController
  def new
    additional_guidance_form = Pages::AdditionalGuidanceForm.new
    render "pages/additional_guidance", locals: { form: @form, page: @page, additional_guidance_form:, preview_html: nil }
  end

  def create
    additional_guidance_form = Pages::AdditionalGuidanceForm.new(additional_guidance_markdown: params[:pages_additional_guidance_form][:additional_guidance_markdown])
    preview_html = GovukFormsMarkdown.render(additional_guidance_form.additional_guidance_markdown)


    render "pages/additional_guidance", locals: { form: @form, page: @page, additional_guidance_form:, preview_html: }
    #
    #     if @details_guidanced_markdown.renderer.warnings.any?
    #       @errors = @details_guidanced_markdown.renderer.warnings.map {|error| DataStruct.new( link: "#", message: error[:message])}.uniq { |p| p.message }
    #     end
    #
    #
    #     @details_guidanced_stripdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
    #     render "pages/detailed_guidance/new", locals: {form: @form, page: Page.new, rendered_markdown:}
  end

end
#
# require 'redcarpet/render_strip'
# class Pages::DetailedGuidanceController < PagesController
#   def new
#     @errors = []
#     render "pages/detailed_guidance/new", locals: {form: @form, page: Page.new}
#   end
#
#   def create
#     if @details_guidanced_markdown.renderer.warnings.any?
#       @errors = @details_guidanced_markdown.renderer.warnings.map {|error| DataStruct.new( link: "#", message: error[:message])}.uniq { |p| p.message }
#     end
#
#
#     @details_guidanced_stripdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
#     render "pages/detailed_guidance/new", locals: {form: @form, page: Page.new, rendered_markdown:}
#   end
# end
