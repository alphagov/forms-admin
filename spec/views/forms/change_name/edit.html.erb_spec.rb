require "rails_helper"

describe "forms/change_name/edit" do
  let(:change_name_form) { Forms::ChangeNameForm.new }

  before do
    controller.request.path_parameters = { form_id: 1 }
    assign :change_name_form, change_name_form
    render
  end

  it "renders the change name form" do
    assert_select "form[action=?][method=?]", change_form_name_path, :post do
      assert_select "input[name=?]", "forms_change_name_form[name]"
    end
  end
end
