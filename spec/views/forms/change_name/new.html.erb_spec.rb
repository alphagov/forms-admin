require "rails_helper"

describe "forms/change_name/new" do
  let(:change_name_form) { Forms::ChangeNameForm.new }

  before do
    assign :change_name_form, change_name_form
    render
  end

  it "renders the change name form" do
    assert_select "form[action=?][method=?]", new_form_path, :post do
      assert_select "input[name=?]", "forms_change_name_form[name]"
    end
  end
end
