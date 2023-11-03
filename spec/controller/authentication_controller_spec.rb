require "rails_helper"

RSpec.describe AuthenticationController, type: :controller do
  controller do
    def index
      raise OmniAuth::Error, :invalid_credentials
    end
  end

  it "rescues from failures with the auth provider" do
    get :index

    expect(response).to have_http_status :bad_request
    expect(response).to have_rendered "errors/sign_in_failed"
  end
end
