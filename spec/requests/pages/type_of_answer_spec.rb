require "rails_helper"

RSpec.describe "TypeOfAnswer controller", type: :request do
  let(:subject) do
    form = create :form
    build :type_of_answer_form, id: form.id
  end

  describe "#new" do
    it 'sets an instance variable for type_of_answer_path' do
      get type_of_answer_new_path(subject.form)
      path = assigns(:type_of_answer_path)
      expect(path).to eq type_of_answer_new_path(subject.form)
    end
  end

  describe "#create" do

  end

  describe "#edit" do

  end

  describe "#update" do

  end
end
