module OmniAuth
  module Strategies
    # The Developer strategy is a very simple strategy that can be used as a
    # placeholder in your application until a different authentication strategy
    # is swapped in. It has zero security and should *never* be used in a
    # production setting.
    #
    # It extends the standard OmniAuth::Strategy::Developer strategy
    # to provide some UI niceties. It is otherwise identical.
    class FormsDeveloper < OmniAuth::Strategies::Developer
      def request_phase
        form = OmniAuth::Form.new(:title => 'User Info', :url => callback_path, :method => 'get')
        options.fields.each do |field|
          form.text_field field.to_s.capitalize.tr('_', ' '), field.to_s
        end
        form.button 'Sign In'

        # Close the current form and start a new one.
        # The new form will get its closing tag from the internally invoked "footer" method
        form.html <<FORM
</form>
<form method='#{options[:method]}' #{"action='#{options[:url]}' " if options[:url]}noValidate='noValidate'>
  <input type="hidden" name="EMAIL" value="example@example.com" />
FORM
        form.button "Sign in as admin"

        form.to_response
      end
    end
  end
end
