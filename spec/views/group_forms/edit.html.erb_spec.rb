require "rails_helper"

RSpec.describe "group_forms/edit.html.erb", type: :view do
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
    render
    expect(rendered).to have_css("h1", text: /Move form/)
  end

  it "renders the page title with error prefix when form has errors" do
    skip "not sure we need this at the moment"

    render
    expect(view.content_for(:page_title)).to eq("Error: Move Form")
  end

  it "sets the back link to the group" do
    render
    expect(view.content_for(:back_link)).to match(group_path(group))
  end

  context "when there are fewer than 10 groups" do
    before do
      allow(group_select).to receive(:groups).and_return(build_list(:group, 9))
    end

    it "renders radio buttons" do
      render
      expect(rendered).to have_css("[data-test-id=\"group-radio\"]")
    end
  end

  context "when there are more than 10 groups" do
    before do
      allow(group_select).to receive(:groups).and_return(build_list(:group, 11))
    end

    it "renders the group select form" do
      render
      expect(rendered).to have_css("[data-test-id=\"group-select\"]")
    end
  end

  context "when there are more than 30 groups" do
    before do
      allow(group_select).to receive(:groups).and_return(build_list(:group, 31))
    end

    it "renders the autocomplete" do
      render
      expect(rendered).to have_css("[data-test-id=\"group-autocomplete\"]")
    end
  end
end
