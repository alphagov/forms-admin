require "rails_helper"

describe "forms/change_name/new" do
  let(:name_form) { Forms::NameForm.new }

  before do
    assign :name_form, name_form
    render
  end

  it "renders the change name form" do
    assert_select "form[action=?][method=?]", new_form_path, :post do
      assert_select "input[name=?]", "forms_name_form[name]"
    end
  end
end
