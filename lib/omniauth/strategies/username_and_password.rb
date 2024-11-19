module OmniAuth
  module Strategies
    class UsernameAndPassword
      include OmniAuth::Strategy

      option :username
      option :password
      option :email_domain

      def request_phase
        form = OmniAuth::Form.new(title: "Sign in to GOV.UK Forms", url: callback_path, method: "post")
        form.text_field "Username", "username"
        form.password_field "Password", "password"
        form.button "Continue"
        form.to_response
      end

      def callback_phase
        return fail!(:invalid_credentials) unless credentials_match?(options.username, options.password)

        super
      end

      uid do
        "#{name}|#{username}"
      end

      info do
        {
          name: username,
          email: "#{username}@#{options.email_domain}",
        }
      end

    private

      def credentials_match?(expected_username, expected_password)
        # This comparison uses & so that it doesn't short circuit and uses
        # `secure_compare` so that length information isn't leaked.
        ActiveSupport::SecurityUtils.secure_compare(username, expected_username) &
          ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
      end

      def username
        request.params["username"]
      end

      def password
        request.params["password"]
      end
    end
  end
end
