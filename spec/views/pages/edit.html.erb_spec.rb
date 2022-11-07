require "rails_helper"

describe "pages/edit.html.erb" do
  let(:question_text) { nil }

  before do
    # Initialize models
    page = Page.new(id: 1, question_text:, form_id: 1)
    form = Form.new(id: 1, name: "Form 1", form_id: 1, pages: [page])
    current_user = OpenStruct.new(uid: 123456)

    # If models aren't persisted, they won't work with form builders correctly
    allow(page).to receive(:persisted?).and_return(true)
    allow(form).to receive(:persisted?).and_return(true)

    # Assign instance variables so they can be accessed from views
    assign(:form, form)
    assign(:page, page)
    assign(:current_user, current_user)
    assign(:answer_types, [])

    # This is normally done in the ApplicationController, but we aren't using
    # that in this test
    ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

    # Render the template with layout to include page title, we could check
    # expect(view.content_for(:title)).to have_content("Question'<> 1 – GOV.UK Forms")
    # instead, but this checks behaviour better
    render(template: "pages/edit", layout: "layouts/application")
  end

  context "when given a title with characters which need escaping" do
    let(:question_text) { "Question'<> 1" }

    it "has the correct title" do
      expect(rendered).to have_title("Question'<> 1 – GOV.UK Forms")
    end
  end
end
