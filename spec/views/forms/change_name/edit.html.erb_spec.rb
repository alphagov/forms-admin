require "rails_helper"

describe "forms/change_name/edit" do
  let(:name_form) { Forms::NameForm.new }

  before do
    controller.request.path_parameters = { form_id: 1 }
    assign :name_form, name_form
    render
  end

  it "renders the change name form" do
    assert_select "form[action=?][method=?]", change_form_name_path, :post do
      assert_select "input[name=?]", "forms_name_form[name]"
    end
  end
end
