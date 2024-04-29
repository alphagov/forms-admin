require "rails_helper"

describe "forms/change_name/new" do
  let(:name_input) { Forms::NameInput.new }

  before do
    assign :name_input, name_input
    render
  end

  it "renders the change name form" do
    assert_select "form[action=?][method=?]", new_form_path, :post do
      assert_select "input[name=?]", "forms_name_input[name]"
    end
  end
end
