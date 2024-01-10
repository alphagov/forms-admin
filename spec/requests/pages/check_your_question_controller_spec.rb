require "rails_helper"

RSpec.describe Pages::CheckYourQuestionController, type: :request do
  describe "GET #index" do
  it "returns a success response" do
    get check_your_question_index_path
    expect(response).to be_successful
  end
end

end
