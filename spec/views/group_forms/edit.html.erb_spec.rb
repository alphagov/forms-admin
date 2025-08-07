require "rails_helper"

RSpec.describe "group_form/edit.html.erb", type: :view do
  let(:group) { create(:group) }
  let(:form) { create :form_record }
  let(:group_select) { Forms::GroupSelect.new(group: group, form: form) }

  before do
    group.group_forms.build(form_id: form.id)
    group.save!

    assign(:id, form.id)
    assign(:form, form)
    assign(:group, group)
    assign(:group_form, group.group_forms.first)
    assign(:group_select, group_select)
  end

  it "renders the page title" do
    skip "there is no H1 yet and will be updated"
    expect(view).to receive(:render).with(group_select, url: group_form_path(group_id: group.id, id: form.id))
    expect(rendered).to have_css("h1", text: "Move Form")
  end

  it "renders the page title with error prefix when form has errors" do
    skip "not sure we need this at the moment"

    render
    expect(view.content_for(:page_title)).to eq("Error: Move Form")
  end

  it "sets the back link to the group" do
    skip "this is not implemented yet, but should be"

    render
    expect(view.content_for(:back_link)).to match(group_path(group))
  end

  it "renders the group select form" do
    skip "this is not implemented yet, but should be"

    expect(view).to receive(:render).with(group_select, url: group_form_path)
    render
  end
end
